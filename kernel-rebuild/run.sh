#!/usr/bin/env bash

./install-deps.sh
./build-kernel.sh
./build-rootfs-and-image.sh
./install-to-minikube-replace.sh -r "$(realpath ./kata-containers-nfs-support)" 
