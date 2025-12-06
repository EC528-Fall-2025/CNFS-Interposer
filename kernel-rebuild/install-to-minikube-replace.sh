#!/usr/bin/env bash

KATA_REPO_PATH=""
KATA_KERNEL_NFS_PATH=""
KATA_KERNEZ_NFS_PATH=""
KATA_IMAGE_NFS_PATH=""
MINIKUBE_INSTALL_PATH="/opt/kata/share/kata-containers/"
MINIKUBE_CONFIG_PATH="/etc/kata-containers/configuration.toml"
MINIKUBE_CONFIG_PATH="/opt/kata/share/defaults/kata-containers/configuration.toml"
INSTALLED_KERNEL_NAME="vmlinux.container"
INSTALLED_KERNEZ_NAME="vmlinuz.container"
INSTALLED_IMAGE_NAME="kata-ubuntu-noble.image"

while [[ $# -gt 0 ]]; do
    case "$1" in
	-r|--kata-repository-path)
	    KATA_REPO_PATH="$2"
	    shift 2
	    ;;
	-k|--kernel)
            KATA_KERNEL_NFS_PATH="$2"
            shift 2
            ;;
	-kz|--kernez)
            KATA_KERNEZ_NFS_PATH="$2"
            shift 2
            ;;
	-i|--image)
	    KATA_IMAGE_NFS_PATH="$2" 
	    shift 2 
	    ;;
        -h|--help)
            echo "Usage: $0 -r <kata-repository-path>" 
            echo "Usage: $0 -k  <kata-kernel-path> -kz <kata-compressed-kernel-path> -i <kata-image-path>" 
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done


if [ -n "$KATA_REPO_PATH" ]; then 
	KATA_KERNEL_NFS_PATH="${KATA_REPO_PATH}/tools/packaging/kernel/kata-nfs-kernel/vmlinux"
	KATA_KERNEZ_NFS_PATH="${KATA_REPO_PATH}/tools/packaging/kernel/kata-nfs-kernel/arch/x86_64/boot/bzImage"
	KATA_IMAGE_NFS_PATH="${KATA_REPO_PATH}/tools/osbuilder/image-builder/kata-containers.img" 
fi 
	

printf "KATA_REPO_PATH         = '%s'\n" "$KATA_REPO_PATH"
printf "KATA_KERNEL_NFS_PATH   = '%s'\n" "$KATA_KERNEL_NFS_PATH"
printf "KATA_KERNEZ_NFS_PATH   = '%s'\n" "$KATA_KERNEZ_NFS_PATH"
printf "KATA_IMAGE_NFS_PATH    = '%s'\n" "$KATA_IMAGE_NFS_PATH"
printf "MINIKUBE_INSTALL_PATH  = '%s'\n" "$MINIKUBE_INSTALL_PATH"
printf "MINIKUBE_CONFIG_PATH   = '%s'\n" "$MINIKUBE_CONFIG_PATH"
printf "INSTALLED_KERNEL_NAME = '%s'\n" "$INSTALLED_KERNEL_NAME"
printf "INSTALLED_KERNEZ_NAME = '%s'\n" "$INSTALLED_KERNEZ_NAME"
printf "INSTALLED_IMAGE_NAME = '%s'\n" "$INSTALLED_IMAGE_NAME"


if [[ -z "$KATA_KERNEL_NFS_PATH" || -z "$KATA_KERNEL_NFS_PATH" || -z "$KATA_IMAGE_NFS_PATH" ]]; then
    echo "please give the mentioned paths"
    exit 1
fi


command -v minikube >/dev/null 2>&1 || die "minikube not found !!"


minikube cp "$KATA_KERNEL_NFS_PATH" "$MINIKUBE_INSTALL_PATH/$INSTALLED_KERNEL_NAME"
minikube cp "$KATA_KERNEZ_NFS_PATH" "$MINIKUBE_INSTALL_PATH/$INSTALLED_KERNEZ_NAME"
minikube cp "$KATA_IMAGE_NFS_PATH" "$MINIKUBE_INSTALL_PATH/$INSTALLED_IMAGE_NAME"
