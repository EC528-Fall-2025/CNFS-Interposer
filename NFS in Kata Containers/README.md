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

# Setup NFS server in host node
## Install the NFS server packages
```bash
sudo apt install -y nfs-kernel-server nfs-common
```

## Create the shared directory
```bash
sudo mkdir -p /nfs/share
sudo chown nobody:nogroup /nfs/share
sudo chmod 777 /nfs/share
```

## Add the export configuration
```bash
echo "/nfs/share *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
```

## Apply the export configuration
```bash
sudo exportfs -ra
```

## Restart the NFS service
```bash
sudo systemctl restart nfs-kernel-server
```
## View the exported shares
```bash
showmount -e localhost
```

## Get the host machine's IP address
```bash
hostname -I | awk '{print $1}'
```

After creating the Kata Pod, we can mount the NFS inside the Pod by running the following commands:

## Enter the pod
```bash
kubectl exec -it kata-nfs -- bash
```
## Install NFS Client
```bash
apt-get update && apt-get install -y nfs-common
```
## Mount NFS
```bash
mkdir -p /mnt/nfs && mount -t nfs "your host node ip address":/nfs/share /mnt/nfs
```










