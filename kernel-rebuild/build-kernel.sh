#!/usr/bin/env bash

pushd kata-containers-nfs-support/tools/packaging/kernel/

./build-kernel.sh -k kata-nfs-kernel setup 
./build-kernel.sh -k kata-nfs-kernel build

popd 