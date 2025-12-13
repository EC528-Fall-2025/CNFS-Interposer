# CSI Driver For NFS using Kata containers (unfinished)
This directory contains the source files that have to be changed in the NFS CSI driver repo so that the CSI driver mounts the NFS server in a Kata container instead of on the node. Start by cloning the [NFS CSI driver repo](https://github.com/kubernetes-csi/csi-driver-nfs).   
The export path out of the Kata container to the consuming pod is not yet implemented.    

## Background
The mount inside the kata container requires changes to the node service of the CSI driver which runs as a daemonset on every node in the cluster. 
This pod contains multiple containers which communicate with one another and the kubelet over Unix domain sockets. Kata containers cannot communicate over Unix domain sockets so running this pod with the kata-runtime will cause the node-driver registrar sidecar to lose contact with the nfs plugin.
As long as a vm boundary is being crossed, this will remain an issue. So we keep the node deployment intact and instead modify the code that runs in the CSI driver to call the Kubernetes API to create a Kata pod on the node. The Kata pod has a runtime script that mounts the NFS server with the arguments passed from the CSI driver. 


## Summary of Changes:
**pkg/nodeserver.go**  
func buildKataPodManifest()   
Creates the manifest for the kata worker pod with the nfs server source and target path info.   

In NodePublishVolume    
Commented out mount on host. Instead, create a kata container on this node and pass along the mount info.    

**pkg/nfs.go**    
Instantiate the K8s client that can be used to create resources on the cluster.    

**deploy/csi-nfs-node.yaml**   
Use modified nfs plugin container    

## Instructions
### Prerequisites
Docker, go, a K8s cluster (We only tested with Minikube)   

### Kata containers install on K8s cluster
For Minikube, follow: [kata minikube installation guide](https://github.com/kata-containers/kata-containers/blob/main/docs/install/minikube-installation-guide.md) 
**Known issues with Kata and Minikube:**    
Some of the deployment scripts do not exist in the latest version of the repo, so:     
```
git checkout 3.21.0
```
Be sure to [use the containerd runtime instead of CRI-O](https://github.com/kata-containers/kata-containers/issues/11311).  

Finally, copy the kernel configuration script from Kata containers install to home directory   
```
minikube ssh "cat /opt/kata/share/kata-containers/config-6.12.47-173" > ~/config-6.12.47-173
```

### Kata container rebuild with NFS kernel modules
Go to kata-containers/tools/packaging/kernel    
Install the dependencies mentioned in the README.md    
Edit your config file from previous step by setting NFS_FS=y    
Use the build-kernel.sh script in kata-containers-tools/packaging/kernel to build the kernel.    
```
./build-kernel.sh -c ~/config-6.12.47-173 -v 6.12.47 setup
./build-kernel.sh build
./build-kernel.sh install
```

### Custom Kata containers install
This is by far the most brittle part of the setup.    
We have to add a new Kata runtime to the Kata containers installation in the K8s cluster to use our custom kernel.    
We have found that overwriting the existing kata-qemu runtime is susceptible to Minikube crashes so it is better to create a new runtime, kata-nfs. There are four additions to make.    

```
# Copy the new kernel into Minikube
minikube ssh
sudo mkdir /opt/kata/share/kata-containers/kata-nfs
exit
minikube cp usr/share/kata-containers/vmlinux.container /opt/kata/share/kata-containers/kata-nfs
# Create a new configuration script
minikube ssh
cd /opt/kata/share/defaults/kata-containers
cp configuration-qemu.toml configuration-nfs.toml
```
Open configuration-nfs.toml in a text editor, and change:    
kernel = "/opt/kata/share/kata-containers/vmlinux.container"    
To     
kernel = "/opt/kata/share/kata-containers/kata-nfs/vmlinux.container"   

```
cd  /etc/containerd/
```
In config.toml, add the following runtime and handler:

[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.kata-nfs]   
runtime_type = "io.containerd.kata-qemu.v2"    
runtime_path = "/opt/kata/bin/containerd-shim-kata-v2"    
privileged_without_host_devices = true    
pod_annotations = ["io.katacontainers.*"]    
       
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.kata-nfs.options]    
ConfigPath = "/opt/kata/share/defaults/kata-containers/configuration-nfs.toml"    

Lastly, register the runtime
```
kubectl apply -f kata-client-pod/runtimeclass-nfs.yaml
```

### Building the image for the Kata client
This is the image that runs in the Kata container. It has the nfs-common userpace tools installed, and it mounts the nfs server at runtime.
```
cd kata-client-pod
docker build -t nfs-client:latest
```
Load image into Minikube vm
```
minikube image load nfs-client:latest
```

### Building the CSI driver
- Clone the csi-driver-nfs repo
- Copy the files in pkg into csi-driver-nfs/pkg
- Copy deploy/csi-nfs-node.yaml into csi-driver-nfs/deploy

Then, from csi-driver-nfs root directory, do:
```
make nfs
```
To build the container image that is used in the deployment script:
```
docker build --build-arg ARCH=amd64 -t kata-nfs-driver:v1 .
```

Load image into Minikube vm
```
minikube image load kata-nfs-driver:v1
```

### Installing the CSI driver on cluster
To install the CSI driver on K8s cluster (local uses your local deployment scripts. Omitting this would pull the unmodified csi-nfs-node.yaml script from remote):
```
./deploy/install-driver.sh . local
```
Check that csi driver is running. Should see that all csi containers were created.
```
kubectl get pods -n kube-system
```

### Test pod
From the csi-nfs-driver-nfs root directory, do:
```
kubectl apply -f deploy/example/pvc-nfs-csi-dynamic.yaml
kubectl apply -f deploy/example/nginx-pod-nfs.yaml
```
This will call the NodePublishVolume method of the node service of the CSI driver which should create a Kata container and mount the NFS server in the Kata container. You should see a new "kata-worker" pod in the kube-system namespace.  
Navigate to /mnt/nfs to confirm the mount.
```
kubectl exec -it <kata-pod-name> -n kube-system -- bash
cd /mnt/nfs
```


## Not yet implemented
Export the directory out of the Kata container so that it can go to the consuming pod.
- Tried: mounting the nfs server onto the same path as a hostpath volume mount into the Kata container.
- Result: Consuming pod that mounts the same hostpath volume does not see NFS contents
- Tried: mounting the nfs server into a subdirectory of a hostpath volume mount
- Result: Consuming pod that mounts the same hostpath volume does not see NFS contents
- Tried: Virtiofs reverse mount. The Kata container runs virtiofsd and exports the nfs directory over a socket. The host tries to mount this with mount -t virtiofs
- Result: At least on Minikube, the virtiofsd tag for the socket that the Kata container exports is not found on the host or specifying a socket directory with -o is marked as "two sources" and causes the mount to fail.

Kata container creation and NFS mounting should be moved to NodeStageVolume. NodePublishVolume should just do a final bind mount from a new staging directory into the targetPath of mount.

Any cleanup of the Kata containers in NodeUnstageVolume or NodeUnpublishVolume.
