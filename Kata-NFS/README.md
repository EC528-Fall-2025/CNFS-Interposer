kata-pod mounts an NFS using a PVC from the NFS CSI driver repo, and exports a directory via a host mount.
An NFS server and NFS CSI have to be running for the mount to work. Follow instructions in NFS CSI repo to understand how to mount NFS.


Can look through the Kata VM filesystem found in host at /opt/kata/share/kata-containers/kata-containers.img to check for kernel modules.
It can be extracted with binwalk.
