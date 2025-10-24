$ kubectl apply -f <host thing>
$ kubectl apply -f <pvc thing>
$ kubectl apply -f <pod thing>

Host directory must be created in the Minikube node, not host node. Do "minikube ssh" and create dir there.
Use containerd runtime if following kata containers installation with minikube, and version 3.21.0 (not latest version)

