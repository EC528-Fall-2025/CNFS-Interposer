## Update the system and Install required tools
```bash
sudo apt update && sudo apt upgrade -y
```
```bash
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common \
    gnupg2 lsb-release wget git build-essential
```
# Install containerd
## Download and add Docker’s GPG key
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y containerd.io
```

## Create the configuration directory and Generate the default configuration
```bash
sudo mkdir -p /etc/containerd

containerd config default | sudo tee /etc/containerd/config.toml
```

## Modify the configuration using sed to set SystemdCgroup = true
```bash
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
```

## Restart the containerd service and Enable containerd to start on boot
```bash
sudo systemctl restart containerd

sudo systemctl enable containerd
```

## Check containerd service status and Check containerd version
```bash
sudo systemctl status containerd

containerd --version
```

# Install K8s
## Permanently disable swap and Verify that swap is disabled (should show 0)
```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
free -h
```

## Create a kernel module configuration file
```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```
## Load the modules immediately
```bash
sudo modprobe overlay
sudo modprobe br_netfilter
```
## Create a sysctl configuration file
```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```
## Apply the sysctl configuration
```bash
sudo sysctl --system
```
## Install required dependencies (if not already installed)
```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```
## Download the Kubernetes GPG key
```bash
sudo mkdir -p /etc/apt/keyrings
```
```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

## Add the Kubernetes repository
```bash
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

## Update package index
```bash
sudo apt-get update
```

## Install kubelet, kubeadm, and kubectl
```bash
sudo apt-get install -y kubelet kubeadm kubectl
```
## Hold the versions to prevent automatic upgrades
```bash
sudo apt-mark hold kubelet kubeadm kubectl
```
## Verify installation
```bash
kubeadm version
kubelet --version
kubectl version --client
```


# Install Kata-runtime
## Set the Kata version (using the latest stable release)
```bash
KATA_VERSION="3.2.0"
```

## Download the Kata Containers tarball, Extract it into the system directory, Clean up the downloaded file
```bash
cd /tmp
wget https://github.com/kata-containers/kata-containers/releases/download/${KATA_VERSION}/kata-static-${KATA_VERSION}-amd64.tar.xz

sudo tar -xvf kata-static-${KATA_VERSION}-amd64.tar.xz -C /

rm kata-static-${KATA_VERSION}-amd64.tar.xz
```

## Add kata-runtime to your PATH
```bash
cd
echo 'export PATH=$PATH:/opt/kata/bin' >> ~/.bashrc
source ~/.bashrc
```

## Check the Kata version
```bash
kata-runtime --version
```
## Back up the current configuration
```bash
sudo cp /etc/containerd/config.toml /etc/containerd/config.toml.backup
```

## Open the configuration file
```bash
sudo nano /etc/containerd/config.toml
```

## Add the following configuration block:
```bash
[plugins."io.containerd.cri.v1.runtime".containerd.runtimes.kata]
  runtime_type = "io.containerd.kata.v2"
  privileged_without_host_devices = true
  [plugins."io.containerd.cri.v1.runtime".containerd.runtimes.kata.options]
    ConfigPath = "/opt/kata/share/defaults/kata-containers/configuration.toml"
```

## Locate the section:
```bash
[plugins."io.containerd.cri.v1.runtime".containerd.runtimes.runc]
```
## Add the above configuration block right below this section, preserving indentation.

<img width="1063" height="607" alt="image" src="https://github.com/user-attachments/assets/de3a0e47-91a1-42d0-a5be-de96dc3f1432" />

## Check whether the Kata configuration exists in the containerd config file
```bash
grep -A 5 "runtimes.kata" /etc/containerd/config.toml
```

## Restart the containerd service and Check the service status
```bash
sudo systemctl restart containerd
sudo systemctl status containerd
```


# Setup K8s cluster
## Initialize the Kubernetes cluster
```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

## Create the .kube directory, copy the admin configuration file and change the file owner
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## Allow scheduling Pods on the control-plane node (since we only have one node)
```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

## Apply the Flannel configuration
```bash
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
```

## View the status of Pods in all namespaces
```bash
kubectl get pods -A
```
## Check node status (it should become Ready)
```bash
kubectl get nodes
```

## Create the RuntimeClass resource
```bash
cat <<EOF | kubectl apply -f -
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: kata
handler: kata
EOF
```
## View the RuntimeClass
```bash
kubectl get runtimeclass
```



# Recompile Kata Kernel to support NFS

## Install the necessary build tools and dependencies

```bash
sudo apt-get update
sudo apt-get install -y build-essential flex bison libelf-dev libssl-dev \
    bc python3 rsync kmod cpio libncurses-dev git wget
```
## Make sure you're in the working directory
```bash
mkdir -p ~/kata-kernel-build
cd ~/kata-kernel-build
```

## Download Linux kernel 6.1.38
```bash
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.38.tar.xz
```

## Extract it
```bash
tar -xf linux-6.1.38.tar.xz
```

## Enter the source directory and Copy Kata's existing config as the base
```bash
cd linux-6.1.38
cp /opt/kata/share/kata-containers/config-6.1.38-114 .config
```
## Use the scripts/config tool to enable NFS-related options
```bash
scripts/config --enable CONFIG_NFS_FS
scripts/config --enable CONFIG_NFS_V2
scripts/config --enable CONFIG_NFS_V3
scripts/config --enable CONFIG_NFS_V4
scripts/config --enable CONFIG_NFS_V4_1
scripts/config --enable CONFIG_NFS_V4_2
scripts/config --enable CONFIG_ROOT_NFS
scripts/config --enable CONFIG_NFS_USE_KERNEL_DNS
scripts/config --enable CONFIG_NFS_FSCACHE
scripts/config --enable CONFIG_NFSD
scripts/config --enable CONFIG_NFSD_V3
scripts/config --enable CONFIG_NFSD_V4
scripts/config --enable CONFIG_NFSD_V4_2_INTER_SSC
```


## Verify that the configuration has been updated
```bash
grep CONFIG_NFS_FS .config
```

## Run olddefconfig to automatically resolve dependencies for the new settings
```bash
make olddefconfig
```

## Start the build
```bash
make -j$(nproc)
```

## Check the generated kernel files
```bash
ls -lh arch/x86/boot/bzImage
ls -lh vmlinux
```

## Verify that NFS support has been compiled in
```bash
grep -E "CONFIG_NFS_FS|CONFIG_NFS_V4" .config
```

## Copy the newly compiled kernel
```bash
sudo cp vmlinux /opt/kata/share/kata-containers/vmlinux-6.1.38-114-nfs
```

## Update the symbolic link to point to the new kernel
```bash
sudo ln -sf /opt/kata/share/kata-containers/vmlinux-6.1.38-114-nfs /opt/kata/share/kata-containers/vmlinux.container
```

## Restart containerd
```bash
sudo systemctl restart containerd
```

# Create a Pod running an NFS server with Kata Containers

## Create a symbolic link to containerd’s default binary path
```bash
sudo ln -s /opt/kata/bin/containerd-shim-kata-v2 /usr/local/bin/containerd-shim-kata-v2
```
## Restart containerd and Restart kubelet
```bash
sudo systemctl restart containerd
sudo systemctl restart kubelet
```

## Check status
```bash
sudo systemctl status containerd
sudo systemctl status kubelet
```


```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: kata-nfs-server
  labels:
    app: kata-nfs-server
spec:
  runtimeClassName: kata
  containers:
  - name: nfs-server
    image: ubuntu:22.04
    command: ["/bin/bash", "-c", "sleep infinity"]
    securityContext:
      privileged: true
      capabilities:
        add:
        - SYS_ADMIN
        - NET_ADMIN
    volumeMounts:
    - name: nfs-storage
      mountPath: /exports
  volumes:
  - name: nfs-storage
    emptyDir: {}
EOF
```

## Check pod's status
```bash
kubectl get pods
```
## Enter the Kata NFS server Pod
```bash
kubectl exec -it kata-nfs-server -- /bin/bash
```
## Install NFS
```bash
apt-get update && apt-get install -y nfs-kernel-server nfs-common
```

## Create the shared directory
```bash
mkdir -p /exports/data
chmod 777 /exports/data
```

## Configure the export rules
```bash
echo "/exports/data *(rw,sync,no_subtree_check,no_root_squash,insecure,fsid=0)" > /etc/exports
```
## Start all NFS services
```bash
rpcbind
mount -t nfsd nfsd /proc/fs/nfsd
rpc.nfsd
rpc.mountd
```
## Apply the export configuration
```bash
exportfs -ra
```

## Verify
```bash
showmount -e localhost
```

## Exit the pod
```bash
exit
```

## Create the Service
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: kata-nfs-service
spec:
  selector:
    app: kata-nfs-server
  ports:
  - name: nfs
    port: 2049
    protocol: TCP
  - name: mountd
    port: 20048
    protocol: TCP
  - name: rpcbind
    port: 111
    protocol: TCP
  clusterIP: None
EOF
```

## Get the IP address of the NFS Server Pod, Make sure to record this IP address
```bash
kubectl get pod kata-nfs-server -o wide
```
## Install the official NFS CSI Driver
```bash
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/install-driver.sh | bash -s master --
```

## Check the CSI driver Pods， You need to wait until all Pods are in the Running state.
```bash
kubectl get pods -n kube-system | grep csi-nfs
```

## Check the CSIDriver resources
```bash
kubectl get csidrivers
```
## Create the StorageClass, Replace 10.244.0.30 with the IP address of your Kata NFS Server Pod.
```bash
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: sc
provisioner: nfs.csi.k8s.io
parameters:
  server: 10.244.0.30
  share: /
reclaimPolicy: Retain
volumeBindingMode: Immediate
mountOptions:
  - nfsvers=4.1
EOF
```

## Check the StorageClass
```bash
kubectl get storageclass
```

## Create the PersistentVolumeClaim
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: sc
EOF
```
## Check the PVC status， When the PVC status is Bound, everything is working correctly, You also need to record the PV name shown under the VOLUME column, as it will be used later.
```bash
kubectl get pvc
```
## Check the PV (it should be created automatically)
```bash
kubectl get pv
```

## Enter the NFS Server Pod again
```bash
kubectl exec -it kata-nfs-server -- /bin/bash
```

## Create the subdirectory required by the CSI driver， Make sure to replace this subdirectory name with the actual PV volume name you obtained earlier, and then exit the pod
```bash
mkdir -p /exports/data/pvc-49819ae4-1cde-408f-a861-4b4e904c91f1
```


## Create a test client Pod
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: kata-nfs-client
spec:
  runtimeClassName: kata
  containers:
  - name: nfs-client
    image: ubuntu:22.04
    command: ["/bin/bash", "-c", "sleep infinity"]
    securityContext:
      privileged: true
      capabilities:
        add:
        - SYS_ADMIN
        - NET_ADMIN
EOF
```

## Enter the client Pod
```bash
kubectl exec -it kata-nfs-client -- /bin/bash
```

## Install NFS client tools
```bash
apt-get update
apt-get install -y nfs-common
```

## Create a mount point
```bash
mkdir -p /mnt
```

## Mount the NFS share directly inside the Kata VM (using the NFS Server’s IP)
```bash
mount -t nfs 10.244.0.13:/ /mnt
```




