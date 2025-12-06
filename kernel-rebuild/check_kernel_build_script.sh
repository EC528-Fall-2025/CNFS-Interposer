wget https://go.dev/dl/go1.25.4.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.25.4.linux-amd64.tar.gz 
echo 'export PATH=$PATH:/usr/local/go/bin/' >> ~/.bashrc
   
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.bashrc
rustc --version 
   
git clone https://github.com/kata-containers/kata-containers.git
cd kata-containers

sudo apt update
sudo apt install git make
sudo apt install qemu-system-x86_64
sudo apt install qmeu-system
sudo apt install qemu-system
sudo apt install flex
sudo apt install bison
sudo apt install libelf-dev


go install github.com/mikefarah/yq/v4@latest
yq
sudo -E "PATH=$PATH" ./build-kernel.sh install
