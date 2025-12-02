kvm-ok
sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
sudo adduser `id -un` libvirt
sudo adduser `id -un` kvm
virsh list --all
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client --output=yaml

minikube start --vm-driver kvm2 --memory 6144 --network-plugin=cni --enable-default-cni --container-runtime=containerd --bootstrapper=kubeadm

git clone --branch 3.22.0 https://github.com/kata-containers/kata-containers.git
pushd kata-containers/tools/packaging/kata-deploy
kubectl apply -f kata-rbac/base/kata-rbac.yaml
kubectl apply -f kata-deploy/base/kata-deploy.yaml
popd 

sleep 180 

pushd kata-containers/tools/packaging/kata-deploy/runtimeclasses
kubectl apply -f kata-runtimeClasses.yaml
popd 
