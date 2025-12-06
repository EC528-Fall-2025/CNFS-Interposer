#!/usr/bin/env bash

pushd kata-containers-nfs-support/tools/osbuilder/rootfs-builder
export distro="ubuntu" # example
export OS_VERSION="noble"
export ROOTFS_DIR="$(realpath ./rootfs)"
sudo rm -rf "${ROOTFS_DIR}"
sudo -E USE_DOCKER=true ./rootfs.sh "${distro}"
popd

pushd  kata-containers-nfs-support/tools/osbuilder/image-builder
sudo -E USE_DOCKER=true ./image_builder.sh "${ROOTFS_DIR}"
popd