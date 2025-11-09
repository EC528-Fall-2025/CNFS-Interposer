#!/bin/bash


# to install Kata Containers
bash -c "$(curl -fsSL https://raw.githubusercontent.com/kata-containers/kata-containers/main/utils/kata-manager.sh) -o"

# To run Kata Containers with Docker
docker run -it --runtime io.containerd.run.kata.v2 --mount type=bind,source=/users/alexhack/kata-share,target=/mnt/kata-share -t --rm docker.io/library/busybox:latest sh
