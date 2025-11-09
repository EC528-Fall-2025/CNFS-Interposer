#!/bin/bash

sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install docker-ce

sudo usermod -aG docker ${USER}
newgrp docker
echo "Docker should appear in groups below"
groups
echo "Check that Docker daemon is running"
sudo systemctl status docker
