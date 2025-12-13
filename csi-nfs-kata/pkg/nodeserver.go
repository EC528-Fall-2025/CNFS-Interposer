/*
Copyright 2017 The Kubernetes Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package nfs

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/container-storage-interface/spec/lib/go/csi"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"k8s.io/klog/v2"
	"k8s.io/kubernetes/pkg/volume"
	mount "k8s.io/mount-utils"

	azcache "sigs.k8s.io/cloud-provider-azure/pkg/cache"

	v1 "k8s.io/api/core/v1"
	k8serrors "k8s.io/apimachinery/pkg/api/errors"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

func buildKataPodManifest(volumeID, nodeID, nfsSource, targetPath string) *v1.Pod {
	// Generate a unique, deterministic name for the Pod
	//	podName := fmt.Sprintf("kata-nfs-worker-%s", volumeID)

	privileged := true
	kataRuntimeClass := "kata-nfs"
	kataInternalMountPath := "/mnt/nfs"

	// Create a new SHA256 hasher
	hash := sha256.New()
	hash.Write([]byte(volumeID))
	volumeDigest := hex.EncodeToString(hash.Sum(nil))
	uniqueID := volumeDigest[:16]
	// Write the raw, complex volumeID to the hasher
	podName := fmt.Sprintf("kata-worker-%s", uniqueID)

	return &v1.Pod{
		ObjectMeta: metav1.ObjectMeta{
			// CRITICAL FIX: Use the short, sanitized Pod Name
			Name:      podName,
			Namespace: "kube-system",
			Labels: map[string]string{
				"app": "kata-nfs-worker",
				// CRITICAL FIX: Use the short, sanitized Volume ID for the label value
				"volume-id": uniqueID,
			},
		},
		Spec: v1.PodSpec{
			// CRITICAL: Forces this Pod to be scheduled on the same node where the CSI driver is running
			NodeName: nodeID,
			// CRITICAL: Triggers the Kata Container Runtime
			RuntimeClassName: &kataRuntimeClass,
			// If the worker crashes, do not restart it (let the CSI driver/Kubelet handle retries)
			RestartPolicy: v1.RestartPolicyNever,
			Volumes: []v1.Volume{
				{
					Name: "kubelet-target-mount", // A simple name for the volume
					VolumeSource: v1.VolumeSource{
						HostPath: &v1.HostPathVolumeSource{
							// CRITICAL: Use the host's targetPath provided by the Kubelet
							Path: targetPath,
							Type: func() *v1.HostPathType {
								t := v1.HostPathDirectoryOrCreate // Ensures the host path exists as a directory
								return &t
							}(),
						},
					},
				},
			},
			Containers: []v1.Container{
				{
					Name:            "nfs-mount-worker",
					Image:           "docker.io/library/nfs-client:latest",
					ImagePullPolicy: "IfNotPresent",
					SecurityContext: &v1.SecurityContext{
						Privileged: &privileged,
					},
					// --- 3. Mount the HostPath into the Container ---
					VolumeMounts: []v1.VolumeMount{
						{
							Name: "kubelet-target-mount", // Matches the Volume name above
							// CRITICAL: Mount it at the internal target path
							MountPath: kataInternalMountPath,
							// You might need Bidirectional propagation for the mount to be visible on the host
							MountPropagation: func() *v1.MountPropagationMode {
								m := v1.MountPropagationBidirectional
								return &m
							}(),
						},
					},
					// Pass the mount instructions via Environment Variables (to be read by the worker Pod)
					Env: []v1.EnvVar{
						{Name: "NFS_SOURCE", Value: nfsSource},
						{Name: "NFS_TARGET_PATH", Value: kataInternalMountPath},
					},
					// Optional: Use a simple command that waits for the vsock connection
					//					Command: []string{"/bin/nfs-worker-app"},
				},
			},
		},
	}
}

// NodeServer driver
type NodeServer struct {
	Driver  *Driver
	mounter mount.Interface
	csi.UnimplementedNodeServer
}

// NodePublishVolume mount the volume
func (ns *NodeServer) NodePublishVolume(ctx context.Context, req *csi.NodePublishVolumeRequest) (*csi.NodePublishVolumeResponse, error) {
	volCap := req.GetVolumeCapability()
	if volCap == nil {
		return nil, status.Error(codes.InvalidArgument, "Volume capability missing in request")
	}
	volumeID := req.GetVolumeId()
	if len(volumeID) == 0 {
		return nil, status.Error(codes.InvalidArgument, "Volume ID missing in request")
	}
	targetPath := req.GetTargetPath()
	if len(targetPath) == 0 {
		return nil, status.Error(codes.InvalidArgument, "Target path not provided")
	}

	lockKey := fmt.Sprintf("%s-%s", volumeID, targetPath)
	if acquired := ns.Driver.volumeLocks.TryAcquire(lockKey); !acquired {
		return nil, status.Errorf(codes.Aborted, volumeOperationAlreadyExistsFmt, volumeID)
	}
	defer ns.Driver.volumeLocks.Release(lockKey)

	mountOptions := volCap.GetMount().GetMountFlags()
	if req.GetReadonly() {
		mountOptions = append(mountOptions, "ro")
	}

	var server, baseDir, subDir string
	subDirReplaceMap := map[string]string{}

	mountPermissions := ns.Driver.mountPermissions
	for k, v := range req.GetVolumeContext() {
		switch strings.ToLower(k) {
		case paramServer:
			server = v
		case paramShare:
			baseDir = v
		case paramSubDir:
			subDir = v
		case pvcNamespaceKey:
			subDirReplaceMap[pvcNamespaceMetadata] = v
		case pvcNameKey:
			subDirReplaceMap[pvcNameMetadata] = v
		case pvNameKey:
			subDirReplaceMap[pvNameMetadata] = v
		case mountOptionsField:
			if v != "" {
				mountOptions = append(mountOptions, v)
			}
		case mountPermissionsField:
			if v != "" {
				var err error
				if mountPermissions, err = strconv.ParseUint(v, 8, 32); err != nil {
					return nil, status.Errorf(codes.InvalidArgument, "invalid mountPermissions %s", v)
				}
			}
		}
	}

	if server == "" {
		return nil, status.Error(codes.InvalidArgument, fmt.Sprintf("%v is a required parameter", paramServer))
	}
	if baseDir == "" {
		return nil, status.Error(codes.InvalidArgument, fmt.Sprintf("%v is a required parameter", paramShare))
	}
	server = getServerFromSource(server)
	source := fmt.Sprintf("%s:%s", server, baseDir)
	if subDir != "" {
		// replace pv/pvc name namespace metadata in subDir
		subDir = replaceWithMap(subDir, subDirReplaceMap)

		source = strings.TrimRight(source, "/")
		source = fmt.Sprintf("%s/%s", source, subDir)
	}

	notMnt, err := ns.mounter.IsLikelyNotMountPoint(targetPath)
	if err != nil {
		if os.IsNotExist(err) {
			if err := os.MkdirAll(targetPath, os.FileMode(mountPermissions)); err != nil {
				return nil, status.Error(codes.Internal, err.Error())
			}
			notMnt = true
		} else {
			return nil, status.Error(codes.Internal, err.Error())
		}
	}
	if !notMnt {
		return &csi.NodePublishVolumeResponse{}, nil
	}

	klog.V(2).Infof("NodePublishVolume: volumeID(%v) source(%s) targetPath(%s) mountflags(%v)", volumeID, source, targetPath, mountOptions)

	// CRITICAL CHECK: Ensure the global client is available
	if globalK8sClientset == nil {
		return nil, status.Error(codes.Internal, "Kubernetes client not initialized (Global is nil)")
	}

	currentNode := os.Getenv("NODE_ID") // Assuming you mapped spec.nodeName to NODE_ID
	if currentNode == "" {
		return nil, status.Error(codes.Internal, "NODE_ID environment variable not set.")
	}
	execFunc := func() error {
		/** Old Code */
		//		return ns.mounter.Mount(source, targetPath, "nfs", mountOptions)

		kataPod := buildKataPodManifest(volumeID, currentNode, source, targetPath)

		// Use your clientset to create the Pod
		_, err := globalK8sClientset.CoreV1().Pods("kube-system").Create(ctx, kataPod, metav1.CreateOptions{})

		if err != nil {
			// Handle specific errors like already exists (Pod is idempotent)
			if k8serrors.IsAlreadyExists(err) {
				klog.V(2).Infof("Kata Pod for volume %s already exists.", volumeID)
			} else {
				klog.Errorf("Failed to create Kata Pod for volume %s: %v", volumeID, err)
				return fmt.Errorf("failed to create Kata Pod: %w", err)
			}
		}
		return nil
	}
	timeoutFunc := func() error { return fmt.Errorf("time out") }
	if err := WaitUntilTimeout(90*time.Second, execFunc, timeoutFunc); err != nil {
		if os.IsPermission(err) {
			return nil, status.Error(codes.PermissionDenied, err.Error())
		}
		if strings.Contains(err.Error(), "invalid argument") {
			return nil, status.Error(codes.InvalidArgument, err.Error())
		}
		return nil, status.Error(codes.Internal, err.Error())
	}

	if mountPermissions > 0 {
		if err := chmodIfPermissionMismatch(targetPath, os.FileMode(mountPermissions)); err != nil {
			return nil, status.Error(codes.Internal, err.Error())
		}
	} else {
		klog.V(2).Infof("skip chmod on targetPath(%s) since mountPermissions is set as 0", targetPath)
	}
	klog.V(2).Infof("volume(%s) mount %s on %s succeeded", volumeID, source, targetPath)
	return &csi.NodePublishVolumeResponse{}, nil
}

// NodeUnpublishVolume unmount the volume
func (ns *NodeServer) NodeUnpublishVolume(_ context.Context, req *csi.NodeUnpublishVolumeRequest) (*csi.NodeUnpublishVolumeResponse, error) {
	volumeID := req.GetVolumeId()
	if len(volumeID) == 0 {
		return nil, status.Error(codes.InvalidArgument, "Volume ID missing in request")
	}
	targetPath := req.GetTargetPath()
	if len(targetPath) == 0 {
		return nil, status.Error(codes.InvalidArgument, "Target path missing in request")
	}

	lockKey := fmt.Sprintf("%s-%s", volumeID, targetPath)
	if acquired := ns.Driver.volumeLocks.TryAcquire(lockKey); !acquired {
		return nil, status.Errorf(codes.Aborted, volumeOperationAlreadyExistsFmt, volumeID)
	}
	defer ns.Driver.volumeLocks.Release(lockKey)

	//	klog.V(2).Infof("NodeUnpublishVolume: unmounting volume %s on %s", volumeID, targetPath)
	//	var err error
	//	extensiveMountPointCheck := true
	//	forceUnmounter, ok := ns.mounter.(mount.MounterForceUnmounter)
	//	if ok {
	//		klog.V(2).Infof("force unmount %s on %s", volumeID, targetPath)
	//		err = mount.CleanupMountWithForce(targetPath, forceUnmounter, extensiveMountPointCheck, 30*time.Second)
	//	} else {
	//		err = mount.CleanupMountPoint(targetPath, ns.mounter, extensiveMountPointCheck)
	//	}
	//	if err != nil {
	//		return nil, status.Errorf(codes.Internal, "failed to unmount target %q: %v", targetPath, err)
	//	}
	//	klog.V(2).Infof("NodeUnpublishVolume: unmount volume %s on %s successfully", volumeID, targetPath)
	//
	return &csi.NodeUnpublishVolumeResponse{}, nil
}

// NodeGetInfo return info of the node on which this plugin is running
func (ns *NodeServer) NodeGetInfo(_ context.Context, _ *csi.NodeGetInfoRequest) (*csi.NodeGetInfoResponse, error) {
	return &csi.NodeGetInfoResponse{
		NodeId: ns.Driver.nodeID,
	}, nil
}

// NodeGetCapabilities return the capabilities of the Node plugin
func (ns *NodeServer) NodeGetCapabilities(_ context.Context, _ *csi.NodeGetCapabilitiesRequest) (*csi.NodeGetCapabilitiesResponse, error) {
	return &csi.NodeGetCapabilitiesResponse{
		Capabilities: ns.Driver.nscap,
	}, nil
}

// NodeGetVolumeStats get volume stats
func (ns *NodeServer) NodeGetVolumeStats(_ context.Context, req *csi.NodeGetVolumeStatsRequest) (*csi.NodeGetVolumeStatsResponse, error) {
	if len(req.VolumeId) == 0 {
		return nil, status.Error(codes.InvalidArgument, "NodeGetVolumeStats volume ID was empty")
	}
	if len(req.VolumePath) == 0 {
		return nil, status.Error(codes.InvalidArgument, "NodeGetVolumeStats volume path was empty")
	}

	// check if the volume stats is cached
	cache, err := ns.Driver.volStatsCache.Get(req.VolumeId, azcache.CacheReadTypeDefault)
	if err != nil {
		return nil, status.Errorf(codes.Internal, "%v", err)
	}
	if cache != nil {
		resp := cache.(*csi.NodeGetVolumeStatsResponse)
		klog.V(6).Infof("NodeGetVolumeStats: volume stats for volume %s path %s is cached", req.VolumeId, req.VolumePath)
		return resp, nil
	}

	if _, err := os.Lstat(req.VolumePath); err != nil {
		if os.IsNotExist(err) {
			return nil, status.Errorf(codes.NotFound, "path %s does not exist", req.VolumePath)
		}
		return nil, status.Errorf(codes.Internal, "failed to stat file %s: %v", req.VolumePath, err)
	}

	volumeMetrics, err := volume.NewMetricsStatFS(req.VolumePath).GetMetrics()
	if err != nil {
		return nil, status.Errorf(codes.Internal, "failed to get metrics: %v", err)
	}

	available, ok := volumeMetrics.Available.AsInt64()
	if !ok {
		return nil, status.Errorf(codes.Internal, "failed to transform volume available size(%v)", volumeMetrics.Available)
	}
	capacity, ok := volumeMetrics.Capacity.AsInt64()
	if !ok {
		return nil, status.Errorf(codes.Internal, "failed to transform volume capacity size(%v)", volumeMetrics.Capacity)
	}
	used, ok := volumeMetrics.Used.AsInt64()
	if !ok {
		return nil, status.Errorf(codes.Internal, "failed to transform volume used size(%v)", volumeMetrics.Used)
	}

	inodesFree, ok := volumeMetrics.InodesFree.AsInt64()
	if !ok {
		return nil, status.Errorf(codes.Internal, "failed to transform disk inodes free(%v)", volumeMetrics.InodesFree)
	}
	inodes, ok := volumeMetrics.Inodes.AsInt64()
	if !ok {
		return nil, status.Errorf(codes.Internal, "failed to transform disk inodes(%v)", volumeMetrics.Inodes)
	}
	inodesUsed, ok := volumeMetrics.InodesUsed.AsInt64()
	if !ok {
		return nil, status.Errorf(codes.Internal, "failed to transform disk inodes used(%v)", volumeMetrics.InodesUsed)
	}

	resp := csi.NodeGetVolumeStatsResponse{
		Usage: []*csi.VolumeUsage{
			{
				Unit:      csi.VolumeUsage_BYTES,
				Available: available,
				Total:     capacity,
				Used:      used,
			},
			{
				Unit:      csi.VolumeUsage_INODES,
				Available: inodesFree,
				Total:     inodes,
				Used:      inodesUsed,
			},
		},
	}

	// cache the volume stats per volume
	ns.Driver.volStatsCache.Set(req.VolumeId, &resp)
	return &resp, err
}

// NodeUnstageVolume unstage volume
func (ns *NodeServer) NodeUnstageVolume(_ context.Context, _ *csi.NodeUnstageVolumeRequest) (*csi.NodeUnstageVolumeResponse, error) {
	return nil, status.Error(codes.Unimplemented, "")
}

// NodeStageVolume stage volume
func (ns *NodeServer) NodeStageVolume(_ context.Context, _ *csi.NodeStageVolumeRequest) (*csi.NodeStageVolumeResponse, error) {
	return nil, status.Error(codes.Unimplemented, "")
}

// NodeExpandVolume node expand volume
func (ns *NodeServer) NodeExpandVolume(_ context.Context, _ *csi.NodeExpandVolumeRequest) (*csi.NodeExpandVolumeResponse, error) {
	return nil, status.Error(codes.Unimplemented, "")
}

func makeDir(pathname string) error {
	err := os.MkdirAll(pathname, os.FileMode(0755))
	if err != nil {
		if !os.IsExist(err) {
			return err
		}
	}
	return nil
}
