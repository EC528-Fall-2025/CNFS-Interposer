package main

import (
    "context"
    "flag"
    "fmt"
    "log"
    "net"
    "os"
    "path/filepath"
    "strings"
    "syscall"

    csi "github.com/container-storage-interface/spec/lib/go/csi"
    "google.golang.org/grpc"
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/reflection"
    "google.golang.org/grpc/status"
)

const (
    pluginName   = "csi.cnfs.interposer.io"
    pluginVer    = "0.1.0"
    volumeRoot   = "/var/lib/cnfs/volumes"
    defaultBytes = int64(1 << 30) // 1Gi just for reporting
)

type driver struct {
    nodeID string
}

func main() {
    endpointFlag := flag.String("endpoint", "unix:///csi/csi.sock", "CSI endpoint")
    nodeIDFlag := flag.String("nodeid", "", "node ID")
    flag.Parse()

    nodeID := *nodeIDFlag
    if nodeID == "" {
        nodeID = os.Getenv("NODE_ID")
    }
    if nodeID == "" {
        log.Fatalf("nodeid must be set via --nodeid or NODE_ID env")
    }

    drv := &driver{nodeID: nodeID}
    if err := drv.run(*endpointFlag); err != nil {
        log.Fatalf("driver exited: %v", err)
    }
}

func (d *driver) run(endpoint string) error {
    if strings.HasPrefix(endpoint, "unix://") {
        endpoint = strings.TrimPrefix(endpoint, "unix://")
    }
    if err := os.RemoveAll(endpoint); err != nil {
        return fmt.Errorf("remove old socket: %w", err)
    }
    if err := os.MkdirAll(filepath.Dir(endpoint), 0755); err != nil {
        return fmt.Errorf("mkdir socket dir: %w", err)
    }

    lis, err := net.Listen("unix", endpoint)
    if err != nil {
        return fmt.Errorf("listen on %s: %w", endpoint, err)
    }
    log.Printf("CSI driver %s starting on %s (nodeID=%s)", pluginName, endpoint, d.nodeID)

    s := grpc.NewServer()
    csi.RegisterIdentityServer(s, d)
    csi.RegisterControllerServer(s, d)
    csi.RegisterNodeServer(s, d)
    reflection.Register(s)

    return s.Serve(lis)
}

// ---------- IdentityServer ----------

func (d *driver) GetPluginInfo(ctx context.Context, req *csi.GetPluginInfoRequest) (*csi.GetPluginInfoResponse, error) {
    return &csi.GetPluginInfoResponse{
        Name:          pluginName,
        VendorVersion: pluginVer,
    }, nil
}

func (d *driver) GetPluginCapabilities(ctx context.Context, req *csi.GetPluginCapabilitiesRequest) (*csi.GetPluginCapabilitiesResponse, error) {
    return &csi.GetPluginCapabilitiesResponse{
        Capabilities: []*csi.PluginCapability{
            {
                Type: &csi.PluginCapability_Service_{
                    Service: &csi.PluginCapability_Service{
                        Type: csi.PluginCapability_Service_CONTROLLER_SERVICE,
                    },
                },
            },
        },
    }, nil
}

func (d *driver) Probe(ctx context.Context, req *csi.ProbeRequest) (*csi.ProbeResponse, error) {
    return &csi.ProbeResponse{}, nil
}

// ---------- ControllerServer ----------

func (d *driver) CreateVolume(ctx context.Context, req *csi.CreateVolumeRequest) (*csi.CreateVolumeResponse, error) {
    if req.GetName() == "" {
        return nil, status.Error(codes.InvalidArgument, "Volume name missing")
    }

    volID := fmt.Sprintf("cnfs-%s", req.GetName())

    return &csi.CreateVolumeResponse{
        Volume: &csi.Volume{
            VolumeId:      volID,
            CapacityBytes: req.GetCapacityRange().GetRequiredBytes(),
        },
    }, nil
}


func (d *driver) DeleteVolume(ctx context.Context, req *csi.DeleteVolumeRequest) (*csi.DeleteVolumeResponse, error) {
    if req.GetVolumeId() == "" {
        return nil, status.Error(codes.InvalidArgument, "Volume ID missing")
    }
    return &csi.DeleteVolumeResponse{}, nil
}


func (d *driver) ControllerGetCapabilities(ctx context.Context, req *csi.ControllerGetCapabilitiesRequest) (*csi.ControllerGetCapabilitiesResponse, error) {
    return &csi.ControllerGetCapabilitiesResponse{
        Capabilities: []*csi.ControllerServiceCapability{
            {
                Type: &csi.ControllerServiceCapability_Rpc{
                    Rpc: &csi.ControllerServiceCapability_RPC{
                        Type: csi.ControllerServiceCapability_RPC_CREATE_DELETE_VOLUME,
                    },
                },
            },
        },
    }, nil
}



func (d *driver) ValidateVolumeCapabilities(ctx context.Context, req *csi.ValidateVolumeCapabilitiesRequest) (*csi.ValidateVolumeCapabilitiesResponse, error) {
    return &csi.ValidateVolumeCapabilitiesResponse{
        Confirmed: &csi.ValidateVolumeCapabilitiesResponse_Confirmed{
            VolumeCapabilities: req.GetVolumeCapabilities(),
        },
    }, nil
}

// Unimplemented / not needed for this demo:
func (d *driver) ControllerPublishVolume(ctx context.Context, req *csi.ControllerPublishVolumeRequest) (*csi.ControllerPublishVolumeResponse, error) {
    return &csi.ControllerPublishVolumeResponse{}, nil
}
func (d *driver) ControllerUnpublishVolume(ctx context.Context, req *csi.ControllerUnpublishVolumeRequest) (*csi.ControllerUnpublishVolumeResponse, error) {
    return &csi.ControllerUnpublishVolumeResponse{}, nil
}
func (d *driver) ListVolumes(ctx context.Context, req *csi.ListVolumesRequest) (*csi.ListVolumesResponse, error) {
    return &csi.ListVolumesResponse{}, nil
}
func (d *driver) GetCapacity(ctx context.Context, req *csi.GetCapacityRequest) (*csi.GetCapacityResponse, error) {
    return &csi.GetCapacityResponse{}, nil
}
func (d *driver) CreateSnapshot(context.Context, *csi.CreateSnapshotRequest) (*csi.CreateSnapshotResponse, error) {
    return nil, status.Error(codes.Unimplemented, "snapshots not supported")
}
func (d *driver) DeleteSnapshot(context.Context, *csi.DeleteSnapshotRequest) (*csi.DeleteSnapshotResponse, error) {
    return nil, status.Error(codes.Unimplemented, "snapshots not supported")
}
func (d *driver) ListSnapshots(context.Context, *csi.ListSnapshotsRequest) (*csi.ListSnapshotsResponse, error) {
    return nil, status.Error(codes.Unimplemented, "snapshots not supported")
}
func (d *driver) ControllerExpandVolume(context.Context, *csi.ControllerExpandVolumeRequest) (*csi.ControllerExpandVolumeResponse, error) {
    return nil, status.Error(codes.Unimplemented, "expand not supported")
}
func (d *driver) ControllerGetVolume(context.Context, *csi.ControllerGetVolumeRequest) (*csi.ControllerGetVolumeResponse, error) {
    return nil, status.Error(codes.Unimplemented, "not supported")
}

// ---------- NodeServer ----------

func (d *driver) NodeGetInfo(ctx context.Context, req *csi.NodeGetInfoRequest) (*csi.NodeGetInfoResponse, error) {
    return &csi.NodeGetInfoResponse{
        NodeId: d.nodeID,
    }, nil
}

func (d *driver) NodeGetCapabilities(ctx context.Context, req *csi.NodeGetCapabilitiesRequest) (*csi.NodeGetCapabilitiesResponse, error) {
    // No special node capabilities; we don't use STAGE/UNSTAGE.
    return &csi.NodeGetCapabilitiesResponse{
        Capabilities: []*csi.NodeServiceCapability{},
    }, nil
}

func (d *driver) NodePublishVolume(ctx context.Context, req *csi.NodePublishVolumeRequest) (*csi.NodePublishVolumeResponse, error) {
    volID := req.GetVolumeId()
    target := req.GetTargetPath()
    if volID == "" || target == "" {
        return nil, status.Error(codes.InvalidArgument, "volumeId and targetPath required")
    }

    source := filepath.Join(volumeRoot, volID)
    if err := os.MkdirAll(source, 0755); err != nil {
        return nil, status.Errorf(codes.Internal, "mkdir source: %v", err)
    }
    if err := os.MkdirAll(target, 0755); err != nil {
        return nil, status.Errorf(codes.Internal, "mkdir target: %v", err)
    }

    // Bind mount source -> target
    if err := syscall.Mount(source, target, "", syscall.MS_BIND, ""); err != nil {
        if err == syscall.EBUSY {
            // Already mounted; OK for idempotency
            return &csi.NodePublishVolumeResponse{}, nil
        }
        return nil, status.Errorf(codes.Internal, "mount %s -> %s: %v", source, target, err)
    }

    return &csi.NodePublishVolumeResponse{}, nil
}

func (d *driver) NodeUnpublishVolume(ctx context.Context, req *csi.NodeUnpublishVolumeRequest) (*csi.NodeUnpublishVolumeResponse, error) {
    target := req.GetTargetPath()
    if target == "" {
        return &csi.NodeUnpublishVolumeResponse{}, nil
    }

    if err := syscall.Unmount(target, 0); err != nil && err != syscall.EINVAL && err != syscall.ENOENT {
        return nil, status.Errorf(codes.Internal, "unmount %s: %v", target, err)
    }
    return &csi.NodeUnpublishVolumeResponse{}, nil
}

// No-op implementations for APIs we don't use:

func (d *driver) NodeStageVolume(context.Context, *csi.NodeStageVolumeRequest) (*csi.NodeStageVolumeResponse, error) {
    return &csi.NodeStageVolumeResponse{}, nil
}
func (d *driver) NodeUnstageVolume(context.Context, *csi.NodeUnstageVolumeRequest) (*csi.NodeUnstageVolumeResponse, error) {
    return &csi.NodeUnstageVolumeResponse{}, nil
}
func (d *driver) NodeGetVolumeStats(context.Context, *csi.NodeGetVolumeStatsRequest) (*csi.NodeGetVolumeStatsResponse, error) {
    return nil, status.Error(codes.Unimplemented, "stats not supported")
}
func (d *driver) NodeExpandVolume(context.Context, *csi.NodeExpandVolumeRequest) (*csi.NodeExpandVolumeResponse, error) {
    return nil, status.Error(codes.Unimplemented, "expand not supported")
}
