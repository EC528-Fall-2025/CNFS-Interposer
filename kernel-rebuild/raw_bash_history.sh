  176  go install github.com/mikefarah/yq/v4@latest
  177  yq
  178  ./build-kernel.sh build
  179  ls
  180  ls ~/
  181  ls ~/go
  182  ls ~/go/bin
  183  vi ~/.source
  184  vi ~/.bashrc
  185  ls /usr/local/go/
  186  ls /usr/local/go/bin
  187  vi ~/.bashrc
  188  echo $HOME
  189  source ~/.bashrc
  190  yq
  191  which yq
  192  echo $PATH
  193  vi ~/.bashrc
  194  source ~/.bashrc
  195  yq
  196  CLEAR
  197  ./build-kernel.sh build
  198  ./build-kernel.sh setup
  199  ./build-kernel.sh build
  200  sudo apt install libelf
  201  sudo apt install libelf-dev
  202  clear
  203  ./build-kernel.sh build
  204  sudo ./build-kernel.sh install
  205  yq
  206  sudo ./build-kernel.sh install
  207  sudo -E "PATH=$PATH" ./build-kernel.sh install
  208  history >> check_kernel_build_script.sh
  209  mv check_kernel_build_script.sh  ~/
  210  cd ~
  211  ls
  212  eval $(ssh-agent -a)
  213  eval $(ssh-agent -s)
  214  ls ~/.ssh
  215  ssh-keygen -t ed25519 -C 'rakin@bu.edu'
  216  ls
  217  cat tempkey.pub
  218  mv tempkey ~/.ssh/
  219  mv tempkey.pub ~/.ssh/
  220  ssh-add ~/.ssh/tempkey
  221  clear
  222  git clone git@github.com:EC528-Fall-2025/CNFS-Interposer.git
  223  cd CNFS-Interposer/
  224  git branch
  225  git switch rakin 
  226  git pull
  227  git merge origin/main
  228  mkdir kernel-rebuild
  229  mv ../check_kernel_build_script.sh kernel-rebuild/
  230  ls kernel-rebuild/
  231  git add .
  232  git commit -m "check kernel rebuild script"
  233  git branch
  234  git config --global --edit
  235  git push 
  236  git checkout -b kernel-rebuild
  237  git push 
  238  git push origin --set-upstream origin kernel-rebuild
  239  git push --set-upstream origin kernel-rebuild
  240  ls
  241  cd kata-containers/tools/packaging/kernel
  242  ls
  243  ./build-kernel.sh -h
  244  ls /opt
  245  kvm-ok
  246  sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
  247  sudo adduser `id -un` libvirt
  248  sudo adduser `id -un` kvm
  249  virsh list --all
  250  kata-runtime 
  251  clear
  252  curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
  253  sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
  254  minikube
  255  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  256  ls
  257  mv kubectl ~/
  258  ls
  259  cd ~
  260  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  261  kubectl version --client --output=yaml
  262  clear
  263  cd CNFS-Interposer/
  264  history >> Kata-Minikube/install.sh
  265  vi install.sh
  266  vi Kata-Minikube/install.sh 
  267  git add .
  268  minikube start --vm-driver kvm2 --memory 6144 --network-plugin=cni --enable-default-cni --container-runtime=containerd --bootstrapper=kubeadm
  269  exit
  270  minikube start --vm-driver kvm2 --memory 6144 --network-plugin=cni --enable-default-cni --container-runtime=containerd --bootstrapper=kubeadm
  271  kubectl get nodes
  272  kubectl get services
  273  curl 10.96.0.1:443
  274  clear
  275  kubectl get nodes
  276  kubectl get pods -n kube-system
  277  kubectl ssh
  278  kubectl exec -it minikube -- sh
  279  minikube ssh
  280  cd kata-containers/tools/packaging/kata-deploy/
  281  ls
  282  git branch
  283  git checkout 3.21.0
  284  ls
  285  cd kata-deploy 
  286  ls
  287  cd ..
  288  kubectl apply -f kata-rbac/base/kata-rbac.yaml
  289  kubectl apply -f kata-deploy/base/kata-deploy.yaml
  290  kubectl get pods
  291  kubectl get pods -n kube-system
  292  cd runtimeclasses/
  293  kubectl apply -f kata-runtimeClasses.yaml 
  294  kubectl get pods -n kube-system
  295  kubectl apply -f kata-runtimeClasses.yaml 
  296  kubectl get runtimeclasses
  297  kubectl get pods
  298  kubectl get pods -n kube-system
  299  minikube ssh
  300  clear
  301  kubectl get pods -n kubectl
  302  kubectl get pods -n kube-system
  303  exit
  304  ls
  305  cd kata-containers/
  306  ls
  307  cd tools/packaging/kata-deploy/
  308  ls
  309  cd runtimeclasses/
  310  ls
  311  vi kata-runtimeClasses.yaml 
  312  cd ..
  313  ls
  314  ls kata-rbac
  315  ls kata-rbac/base
  316  vi kata-rbac/base/kata-rbac.yaml 
  317  vi kata-deplooy/base/kata-deploy.yaml
  318  vi kata-deploy/base/kata-deploy.yaml 
  319  minikube 
  320  clear
  321  ls
  322  cd kata-containers/
  323  ls
  324  cd tools 
  325  ll
  326  cd packaging/
  327  ls
  328  ll
  329  cd kernel
  330  ll
  331  ll configs
  332  grep --help
  333  grep -r 'NFS' 
  334  grep -r 'NFS' configs/
  335  ll configs
  336  ll configs/fragments
  337  ll configs/fragments/x86_64/
  338  grep -r 'NFS'  configs/fragments/x86_64/
  339  ./build-kernel.sh build
  340  ./build-kernel.sh setup
  341  ls
  342  ll
  343  vi  configs/fragments/x86_64/.config
  344  ./build-kernel.sh -h
  345  ./build-kernel.sh setup
  346  ./build-kernel.sh build
  347  ls
  348  find . -name "*bzImage*"
  349  rm error.error 
  350  ls
  351  ll
  352  rm -r kata-linux-*
  353  ll
  354  ll configs/fragments/x86_64/
  355  grep 'NFS' configs/fragments/x86_64/.config
  356  ./build-kernel.sh setup
  357  ./build-kernel.sh build
  358  ./build-kernel.sh -h
  359  ./build-kernel.sh -k kata-nfs-kernel build
  360  ./build-kernel.sh -k kata-nfs-kernel setup
  361  ./build-kernel.sh -k kata-nfs-kernel build
  362  ls
  363  ll kata-nfs-kernel/
  364  ./build-kernel.sh -k kata-nfs-kernel install
  365  sudo ./build-kernel.sh -k kata-nfs-kernel install
  366  which ya
  367  which yq
  368  yq
  369  clear
  370  vi ~/.bashrc
  371  source ~/.bashrc
  372  sudo ./build-kernel.sh -k kata-nfs-kernel install
  373  sudo -E "PATH=$PATH" ./build-kernel.sh -k kata-nfs-kernel install
  374  sudo ctr run --runtime io.containerd.kata.v2 -d docker.io/library/ubuntu:latest testdebug
  375  ctr
  376  sudo apt install ocntainerd
  377  sudo apt update
  378  sudo apt install containerd
  379  sudo ctr run --runtime io.containerd.kata.v2 -d docker.io/library/ubuntu:latest testdebug
  380  sudo ctr pull docker.io/library/ubuntu:latest
  381  sudo ctr image pull docker.io/library/ubuntu:latest
  382  sudo ctr run --runtime io.containerd.kata.v2 -d docker.io/library/ubuntu:latest testdebug
  383  docker
  384  sudo apt install docker 
  385  clear
  386  # Add Docker's official GPG key:
  387  sudo apt update
  388  sudo apt install ca-certificates curl
  389  sudo install -m 0755 -d /etc/apt/keyrings
  390  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  391  sudo chmod a+r /etc/apt/keyrings/docker.asc
  392  # Add the repository to Apt sources:
  393  sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
  394  Types: deb
  395  URIs: https://download.docker.com/linux/ubuntu
  396  Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
  397  Components: stable
  398  Signed-By: /etc/apt/keyrings/docker.asc
  399  EOF
  400  sudo apt update
  401  sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  402  cd ../
  403  cd ..
  404  ls
  405  cd osbuilder
  406  ls
  407  cd rootfs-builder/
  408  ls
  409  ./rootfs.sh
  410  ./rootfs.sh -l
  411  ls
  412  ll
  413  sudo -E 'USE_DOCKER=true' ./rootfs.sh ubuntu
  414  sudo -E 'USE_DOCKER=true OS_VERSION=22.04' ./rootfs.sh ubuntu
  415  sudo -E 'USE_DOCKER=true;OS_VERSION=22.04' ./rootfs.sh ubuntu
  416  sudo -E 'USE_DOCKER=true' ./rootfs.sh ubuntu
  417  export OS_VERSION=24.04
  418  sudo -E 'USE_DOCKER=true' ./rootfs.sh ubuntu
  419  cd ..
  420  ls
  421  cd image-builder/
  422  ls
  423  ./image_builder.sh 
  424  ./image_builder.sh -h
  425  cd ~
  426  clear
  427  export distro='ubuntu'
  428  export ROOTFS_DIR="$(realpath kata-containers/tools/osbuilder/rootfs-builder/rootfs)"
  429  sudo rm -rf "${ROOTFS_DIR}"
  430  pushd kata-containers/tools/osbuilder/rootfs-builder/
  431  ls
  432  script -fec 'sudo -E USE_DOCKER=true ./rootfs.sh "${distro}"'
  433  export OS_VERSION=22.04
  434  script -fec 'sudo -E USE_DOCKER=true ./rootfs.sh "${distro}"'
  435  cd ..
  436  git checkout 3.22.0
  437  cd tools/osbuilder/rootfs-builder/
  438  script -fec 'sudo -E USE_DOCKER=true ./rootfs.sh "${distro}"'
  439  ./rootfs.sh --help
  440  ./rootfs.sh -h
  441  export OS_VERSION=noble
  442  script -fec 'sudo -E USE_DOCKER=true ./rootfs.sh "${distro}"'
  443  cd ../image-builder/
  444  ls
  445  script -fec 'sudo -E USE_DOCKER=true ./image_builder.sh "${ROOTFS_DIR}"'
  446  ls
  447  commit="$(git log --format=%h -1 HEAD)"
  448  date="$(date +%Y-%m-%d-%T.%N%z)"
  449  image="kata-containers-${date}-${commit}"
  450  sudo install -o root -g root -m 0640 -D kata-containers.img "/usr/share/kata-containers/${image}"
  451  (cd /usr/share/kata-containers && sudo ln -sf "$image" kata-containers.img)
  452  sudo kata-runtime check
  453  sudo kata-monitor
  454  sudo ctr run  --runtime io.containerd.kata.v2 -d docker.io/library/ubuntu:latest testdebug
  455  ctr
  456  ctr snapshots
  457  ctr snapshots rm testdebug
  458  sudo ctr run  --runtime io.containerd.kata.v2 -d docker.io/library/ubuntu:latest testdebug
  459  ctr snapshots list
  460  ctr snapshots rm testdebug
  461  ctr snapshots list
  462  ctr snapshots rm e8bce0aabd687e9ee90e0bada33884f40b277196f72aac9934357472863a80ae
  463  ctr --namespace default list
  464  ctr --namespace default tasks list
  465  ctr --namespace default containers list
  466  ctr --namespace default containers delete testdebug
  467  ctr --namespace default containers list
  468  sudo ctr run  --runtime io.containerd.kata.v2 -d docker.io/library/ubuntu:latest testdebug
  469  which virtiofsd
  470  sudo apt install virtiofsd
  471  which virtiofsd
  472  sudo ctr run  --runtime io.containerd.kata.v2 -d docker.io/library/ubuntu:latest testdebug
  473  sudo ctr --namespace default containers list
  474  sudo ctr --namespace default containers delete testdebug
  475  sudo ctr run  --runtime io.containerd.kata.v2 -d docker.io/library/ubuntu:latest testdebug
  476  kata-runtime exec testdebug
  477  sudo kata-runtime exec testdebug
  478  kata-runtime exec testdebug
  479  ll /run/vc/sbs/testdebug/shim-monitor.sock 
  480  chmod 660 /run/vc/sbs/testdebug/shim-monitor.sock 
  481  sudo chmod 660 /run/vc/sbs/testdebug/shim-monitor.sock 
  482  kata-runtime exec testdebug
  483  ps aux | grep qemu
  484  ctr task exec -t testdebug bash
  485  ctr --namespace default containers list
  486  ctr --namespace default containers delete testdebug
  487  ctr --namespace default containers stop testdebug
  488  ctr --namespace default containers help
  489  ctr --namespace default containers rm testdebug
  490  sudo ctr --namespace default containers rm testdebug
  491  ctr --namespace default task ls
  492  ctr --namespace default task kill -s KILL testdebug
  493  ctr --namespace default task rm testdebug
  494  ctr --namespace default containers rm testdebug
  495  ls
  496  sudo ctr run --runtime io.containerd.kata.v2 -t docker.io/library/ubuntu:latest testdebug /bin/bash
  497  ip a
  498  clear
  499  ls
  500  sudo ctr task exec -t testdebug bash
  501  kata-runtime exec testdebug
  502  ctr containers list
  503  ctr containers remove testdebug
  504  ctr snapshots
  505  ctr snapshots list
  506  clear
  507  reboot
  508  sudo reboot
  509  ls
  510  sudo reboot
  511  exit
  512  reboot
  513  ctr containers list
  514  sudo ctr run --runtime io.containerd.kata.v2 -d docker.io/library/ubuntu:latest testdebug /bin/bash
  515  ctr containers list
  516  ctr containers rm testdebug
  517  ctr task list
  518  ctr task help
  519  ctr task kill 3114
  520  ctr task kill testdebug
  521  ctr containers rm testdebug
  522  ctr containers list
  523  sudo ctr run --runtime io.containerd.kata.v2 -t docker.io/library/ubuntu:latest testdebug /bin/bash
  524  modprobe overlay
  525  modprobe br_netfilter
  526  sudo modprobe br_netfilter
  527  ctr containers list
  528  ctr containers rm testdebug
  529  clear
  530  minikub
  531  minikube
  532  kubectl
  533  kubectl get nodes
  534  minikube 
  535  kubectl get nodes
  536  clear
  537  minikube minikube start --vm-driver kvm2 --memory 6144 --network-plugin=cni --enable-default-cni --container-runtime=containerd --bootstrapper=kubeadm
  538  minikube start --vm-driver kvm2 --memory 6144 --network-plugin=cni --enable-default-cni --container-runtime=containerd --bootstrapper=kubeadm
  539  kubectl get nodes
  540  kubectl get pods
  541  kubectl get pods -n kube-system
  542  clear
  543  minikube ssh
  544  kubectl get pods -n kube-system
  545  minikube stop
  546  minikube start
  547  kubectl get pods -n kube-system
  548  cd kata-containers/
  549  ls
  550  cd tools/packaging/kata-deploy/
  551  ls
  552  cd examples/
  553  ls
  554  vi ubuntu.yaml
  555  kubectl apply -f test-deploy-kata-qemu.yaml 
  556  kubectl get pods
  557  kubectl exect -it prometheus-kata-qemu-dc77fff6b-955xq -- sh
  558  kubectl exec -it prometheus-kata-qemu-dc77fff6b-955xq -- sh
  559  kubectl exec -it prometheus-kata-qemu-dc77fff6b-955xq -- bash
  560  kubectl exec -it prometheus-kata-qemu-dc77fff6b-955xq -- sh
  561  vi test-deploy-kata-qemu.yaml 
  562  vi ubuntu.yaml 
  563  uname -r
  564  kubectl apply -f ubuntu.yaml 
  565  kubectl get pods
  566  kubectl exec -it ubuntu -- bash
  567  kubectl get pods
  568  clear
  569  kubectl get pods
  570  minikube
  571  clear
  572  kubectl
  573  kubectl get pods
  574  kubectl get nodesw
  575  exit
  576  kubectl get pods
  577  minikube kubectl get pods
  578  minikube stop
  579  clear
  580  reboot
  581  cd kata-containers/
  582  ls
  583  cd tools/packaging/kernel/
  584  ls
  585  ll
  586  ll kata-nfs-kernel
  587  vi build-kernel.sh 
  588  ./build-kernel.sh -k kata-nfs-kernel install 
  589  sudo ./build-kernel.sh -k kata-nfs-kernel install 
  590  sudo -E "PATH=$PATH" ./build-kernel.sh -k kata-nfs-kernel install 
  591  vi build-kernel.sh 
  592  ll kata-nfs-kernel/
  593  ll kata-nfs-kernel/arch/x86_64/boot/
  594  minikube cp kata-nfs-kernel/
  595  minikube cp kata-nfs-kernel/vmlinux /opt/kata/share/kata-containers/vmlinux-6.12.47-172-nfs
  596  minikube cp kata-nfs-kernel/arch/x86_64/boot/bzImage  /opt/kata/share/kata-containers/vmlinuz-6.12.47-172-nfs
  597  cd ..
  598  ls
  599  cd ..
  600  ls
  601  cd tools/
  602  ls
  603  cd osbuilder/
  604  cd image-builder/
  605  ls
  606  minikube cp kata-containers.img /opt/kata/share/kata-containers/kata-ubuntu-noble-nfs.image
  607  minikube cache delete
  608  minikube cp kata-containers.img /opt/kata/share/kata-containers/kata-ubuntu-noble-nfs.image
  609  minikube start
  610  kubectl get pods
  611  kubectl delete pod prometheus-kata-qemu-dc77fff6b-955xq
  612  kubectl get pods
  613  kubectl delete pod prometheus-kata-qemu-dc77fff6b-gz44h
  614  kubectl get pods
  615  kubectl exec -it ubuntu -- bash
  616  clear
  617  kubectl get pods
  618  kubectl get deployments
  619  kubectl get pods
  620  exit
  621  sudo reboot
  622  clear
  623  l
  624  ll
  625  exi
  626  k
  627  j
  628  clear
  629  reboot
  630  sudo re
  631  clear
  632  ssh rakin000@pc67.cloudlab.umass.edu
  633  clear
  634  ls
  635  ext
  636  eixt
  637  exit
  638  clear
  639  minikube start
  640  kubectl get pods
  641  kubectl get deployments
  642  kubectl delete deployment prometheus-kata-qemu
  643  kubectl get pods
  644  clear
  645  kubectl get pods
  646  clear
  647  kubectl exect -it ubuntu -- sh
  648  kubectl exec -it ubuntu -- sh
  649  exit
  650  ip addr
  651  ls /demo
  652  echo "hi" >> /demo/hi.txt
  653  sudo echo "hi" >> /demo/hi.txt
  654  chmod 777 /demo
  655  sudo chmod 777 /demo
  656  sudo echo "hi" >> /demo/hi.txt
  657  sudo chmod 777 /dem/hi.txt
  658  sudo chmod 777 /demo/hi.txt
  659  cat /demo/hi.txt
  660  ls
  661  cd kata-containers
  662  ls
  663  cd tools
  664  ls
  665  cd packaging
  666  ls
  667  kata-runtime
  668  clear
  669  docker run -it --runtime io.containerd.run.kata.v2 -t --rm docker.io/library/busybox:latest sh
  670  sudo docker run -it --runtime io.containerd.run.kata.v2 -t --rm docker.io/library/busybox:latest sh
  671  sudo docker run -it --runtime io.containerd.run.kata.v2 -t --rm docker.io/library/ubuntu:latest sh
  672  apt install containernetworking-plugins 
  673  sudo apt install containernetworking-plugins 
  674  ls
  675  sudo docker run -it --runtime io.containerd.run.kata.v2 -t --rm docker.io/library/ubuntu:latest sh
  676  exit
  677  clear
  678  ip sudo apt install containernetworking-plugins -y
  679  sudo sysctl -w net.ipv4.ip_forward=1
  680  sudo iptables -P FORWARD ACCEPT
  681  sudo iptables -t nat -A POSTROUTING -s 10.88.0.0/16 -j MASQUERADE
  682  sudo systemctl restart containerd
  683  sudo apt install containernetworking-plugins -y
  684  sudo sysctl -w net.ipv4.ip_forward=1
  685  sudo iptables -P FORWARD ACCEPT
  686  sudo iptables -t nat -A POSTROUTING -s 10.88.0.0/16 -j MASQUERADE
  687  sudo systemctl restart containerd
  688  sudo docker run -it --runtime io.containerd.run.kata.v2 -t --rm docker.io/library/ubuntu:latest sh
  689  ip a
  690  ap route
  691  clear
  692  ip route
  693  ip a
  694  ls
  695  ll
  696  kubectl get pods
  697  kubectl exec -it ubuntu -- sh
  698  clear
  699  kubectl exec -it ubuntu -- sh
  700  cd kata-containers/tools/packaging/kata-deploy/
  701  ls
  702  cd examples/
  703  ls
  704  vi ubuntu.yaml 
  705  kubectl delete pod ubuntu
  706  kubectl apply -f ubuntu.yaml 
  707  vi ubuntu.yaml 
  708  clear
  709  kubectl apply -f ubuntu.yaml 
  710  kubectl get pods
  711  kubectl exec -it ubuntu -- sh
  712  vi ubuntu.yaml 
  713  kubectl apply -f ubuntu.yaml 
  714  kubectl delete pod ubuntu
  715  kubectl apply -f ubuntu.yaml 
  716  kubectl get pods
  717  nfs
  718  mkdir -p /demo
  719  sudo mkdir -p /demo
  720  vi /etc/exports
  721  sudo apt install nfs-server -y
  722  ls
  723  service 
  724  service --status-all
  725  vi /etc/exports
  726  sudo vi /etc/exports
  727  exportfs -ra
  728  sudo  exportfs -ra
  729  exportfs -v
  730  sudo exportfs -v
  731  clear
  732  kubectl exec -it ubuntu -- sh
  733  kubectl pod delete ubuntu
  734  kubectl delete delete ubuntu
  735  kubectl delete pod ubuntu
  736  minikube ssh 
  737  ip addr
  738  minikube ssh
  739  vi reach-host.yaml
  740  kubectl apply -f reach-host.yaml 
  741  kubectl get pods
  742  kubectl exec -it reach-host -- sh
  743  clear
  744  vi ubuntu.yaml 
  745  kubectl apply -f ubuntu.yaml 
  746  kubectl get pods
  747  kubectl exec -it ubuntu -- sh
  748  minikube ssh
  749  clear
  750  ls
  751  minikube ssh
  752  minikube ssh 
  753  lls
  754  ls
  755  clear
  756  ll kata-containers/tools/packaging/kernel/kata-nfs-kernel
  757  ll kata-containers/tools/packaging/kernel/kata-nfs-kernel/arch/x86_64/boot/
  758  ll kata-containers/tools/packaging/kernel/kata-nfs-kernel/arch/x86_64/boot/bzImage
  759  clear
  760  ll kata-containers/tools/osbuilder/
  761  ll kata-containers/tools/osbuilder/image-builder/
  762  minikube
  763  minikube ssh
  764  ls
  765  cd kata-containers/
  766  cd ..
  767  cd CNFS-Interposer/
  768  ls
  769  cd kernel-rebuild/
  770  ls
  771  ./install-to-minikube.sh -r ~/kata-containers/
  772  minikube ssh
  773  kubectl get pods
  774  exportfs -v
  775  sudo exportfs -v
  776  kubectl exec -it ubuntu -- sh
  777  clear
  778  kubectl get pods
  779  minikube
  780  minikube ssh
  781  minikube start 
  782  minikube ssh 
  783  kubectl get pods
  784  kubectl delete pod ubuntu 
  785  minikube ssh
  786  cd ~/kata-containers/tools/packaging/kata-deploy/examples
  787  ls
  788  ln ubuntu.yaml ~/CNFS-Interposer/kernel-rebuild/ubuntu-sample.yaml
  789  ll ~/CNFS-Interposer/kernel-rebuild/ubuntu-sample.yaml 
  790  vi ubuntu.yaml
  791  kubectl apply -f ubuntu.yaml 
  792  kubectl get pods
  793  kubectl exec -it ubuntu sh 
  794  kubectl exec -it ubuntu -- sh 
  795  clear
  796  kubectl exec -it ubuntu -- sh 
  797  minikube
  798  kubectl get pods
  799  minikube ssh
  800  cd kata-containers/
  801  ls
  802  cd ..
  803  ls
  804  cd CNFS
  805  cd CNFS-Interposer/
  806  git branch
  807  ls
  808  cd kernel-rebuild/
  809  touch install-to-minikube.sh
  810  vi install-to-minikube.sh 
  811  chmod +x install-to-minikube.sh 
  812  ./install-to-minikube.sh 
  813  ./install-to-minikube.sh -i fsadf
  814  ./install-to-minikube.sh -i fsadf -v fasdfasd
  815  ./install-to-minikube.sh -i fsadf -v True
  816  vi install-to-minikube.sh 
  817  ./install-to-minikube.sh -i fsadf -v 
  818  clear
  819  ./install-to-minikube.sh -
  820  vi install-to-minikube.sh 
  821  ./install-to-minikube.sh  -r ~/kata-containers/
  822  vi install-to-minikube.sh 
  823  ./install-to-minikube.sh  -r ~/kata-containers/
  824  vi install-to-minikube.sh 
  825  ./install-to-minikube.sh  -r ~/kata-containers/
  826  minikube ssh
  827  minikube stop
  828  ls
  829  git a dd .
  830  git add .
  831  git commit -m "copy kernel and image to minikube"
  832  git pus h
  833  git push
  834  cd ..
  835  git push 
  836  ssh-add ~/.ssh/tempkey
  837  eval $(ssh-agent -s)
  838  ssh-add ~/.ssh/tempkey
  839  git push 
  840  minikube ssh
  841  clear
  842  minikube start
  843  more kernel-rebuild/install-to-minikube.sh 
  844  sudo exportfs -v
  845  minikube ssh -- ps aux | grep qemu
  846  minikube ssh 
  847  minikube stop
  848  cd kernel-rebuild/
  849  vi install-to-minikube.sh 
  850  ./install-to-minikube.sh ~/kata-containers/
  851  ./install-to-minikube.sh -r ~/kata-containers/
  852  vi install-to-minikube.sh 
  853  cd ..
  854  git add .
  855  git commit -m "update"
  856  git push 
  857  cd ../kata-containers/
  858  ls
  859  cd tools/packaging/
  860  ls
  861  cd kernel/
  862  ls
  863  ls configs
  864  ls configs/fragments
  865  ls
  866  ls configs/fragments/x86_64/.config
  867  vi configs/fragments/x86_64/.config
  868  sed -n '/CONFIG_NFS/p' configs/fragments/x86_64/.config.old
  869  ls
  870  more README.md 
  871  ls
  872  cd kata-nfs-kernel
  873  ls
  874  ls Kconfig 
  875  vi Kconfig 
  876  cd ..
  877  ./build-kernel.sh -k 'kata-nfs-kernel-modules' setup
  878  vi build-kernel.sh 
  879  sed -n '/CONFIG_NFS/p' configs/fragments/x86_64/.config
  880  cd kata-nfs-kernel-modules/
  881  ls
  882  cd arch
  883  ls
  884  cat Kconfig 
  885  cat Kconfig | grep CONFIG_FSCACHE
  886  cd ..
  887  ls
  888  cd ..
  889  ls
  890  cd kernel-nfs
  891  cd kata-nfs-kernel-modules/
  892  ls
  893  grep -r 'CONFIG'
  894  find . -name "*config*"
  895  ll kernel/configs
  896  cd ..
  897  ls
  898  ./build-kernel.sh -k kata-nfs-kernel-modules setup
  899  rm -rf kata-nfs-kernel*
  900  ./build-kernel.sh -k kata-nfs-kernel-modules setup
  901  vi build-kernel.sh 
  902  ls
  903  cd configs
  904  ls
  905  ls -d
  906  cd fragments 
  907  ls
  908  cd x86_64/
  909  ls
  910  grep -r 'CONFIG_NFS'
  911  ll confidential/
  912  cd ..
  913  grep -r 'CONFIG_NFS'
  914  vi x86_64_kata_kvm_4.14.x 
  915  clear
  916  ;;cd ..
  917  ls
  918  cd ..
  919  ls
  920  rm -rf kata-nfs-kernel-modules/
  921  rm configs/fragments/x86_64/.config
  922  rm configs/fragments/x86_64/.config.old
  923  ll configs
  924  ll configs/fragments
  925  ll configs/fragments/common
  926  grep -r 'CONFIG_NFS' configs/fragments/common
  927  grep -r 'CONFIG_NFS' 
  928  ./build-kernel.sh -k kata-nfs setup
  929  vi configs/fragments/x86_64/.conf
  930  vi configs/fragments/x86_64/.config 
  931  cd configs
  932  ls
  933  cd fragments
  934  ls
  935  grep 'CONFIG_NFS' whitelist.conf
  936  grep 'CONFIG_MODULES' whitelist.conf
  937  vi whitelist
  938  vi whitelist.conf
  939  cd common
  940  ls
  941  grep "CONFIG_NFS" .
  942  grep -r "CONFIG_NFS" 
  943  vi base.conf
  944  grep -r "CONFIG_MODULES" 
  945  cd ..
  946  grep -r "CONFIG_MODULES"
  947  cd ../..
  948  ls
  949  ll
  950  rm -rf kata-linux-6.12.47-166/
  951  cd configs/
  952  ls
  953  cd fragments/
  954  ls
  955  cd common
  956  ls
  957  vi base.conf
  958  vi nfs.conf
  959  ls
  960  clear
  961  cd ..
  962  ls
  963  cd ..
  964  ls
  965  cd fragments/
  966  ls
  967  cd x86_64/
  968  ls
  969  rm -rf .config 
  970  rm -rf .config.old
  971  cd ..
  972  ./build-kernel.sh -k kata-nfs setup
  973  ls
  974  rm -rf kata-nfs
  975  ./build-kernel.sh -k kata-nfs setup
  976  vi kata_config_version 
  977  rm -rf kata-nfs
  978  ./build-kernel.sh -k kata-nfs setup
  979  vi configs/fragments/x86_64/.config
  980  vi configs/fragments/common/
  981  vi configs/fragments/common/base.conf 
  982  vi configs/fragments/common/nfs.conf 
  983  ./build-kernel.sh -k kata-nfs setup
  984  rm -rf kata-nfs
  985  ./build-kernel.sh -k kata-nfs setup
  986  ./build-kernel.sh -k kata-nfs build
  987  cat configs/fragments/common/nfs
  988  cat configs/fragments/common/nfs.conf 
  989  rm -rf kata-nfs/
  990  ls
  991  vi configs/fragments/common/nfs.conf 
  992  ./build-kernel.sh setup
  993  vi configs/fragments/common/nfs.conf 
  994  clear
  995  ./build-kernel.sh setup
  996  rm -rf kata-linux-6.12.47-172_nfs
  997  ./build-kernel.sh setup
  998  vi configs/fragments/common/nfs.conf 
  999  rm -rf kata-linux-6.12.47-172_nfs
 1000  ./build-kernel.sh setup
 1001  vi configs/fragments/common/nfs.conf 
 1002  clear
 1003  rm -rf kata-linux-6.12.47-172_nfs/
 1004  clear
 1005  ls
 1006  ./build-kernel.sh setup
 1007  vi configs/fragments/common/nfs.conf 
 1008  clear
 1009  rm -rf kata-linux-6.12.47-172_nfs/
 1010  ./build-kernel.sh setup
 1011  ./build-kernel.sh build
 1012  sudo apt update
 1013  sudo apt install libssl-dev
 1014  ./build-kernel.sh build
 1015  ls
 1016  cd kata-linux-6.12.47-172_nfs/
 1017  ls
 1018  ls arch/x86_64/
 1019  ls arch/x86_64/boot/
 1020  git branch
 1021  git remote -v
 1022  git remote add fork git@github.com:rakin000/kata-containers.git
 1023  git remote -v
 1024  git checkout -b nfs-support
 1025  git push fork --set-upstream nfs-support
 1026  git add .
 1027  cd ~/kata-containers/
 1028  git add .
 1029  sudo git add .
 1030  git commit -m "nfs"
 1031  sudo git commit -m "nfs"
 1032  git push 
 1033  cd -
 1034  clear
 1035  ls
 1036  cd ..
 1037  ls
 1038  ln -s kata-nfs-kernel kata-linux-6.12.47-172_nfs
 1039  ls
 1040  ln kata-nfs-kernel kata-linux-6.12.47-172_nfs
 1041  mkdir kata-nfs-kernel
 1042  ln kata-nfs-kernel kata-linux-6.12.47-172_nfs
 1043  ls
 1044  rm -rf kata-nfs-kernel
 1045  rm -rf kata-linux-6.12.47-172_nfs*
 1046  ./build-kernel.sh -k kata-nfs-kernel setup 
 1047  ./build-kernel.sh -k kata-nfs-kernel build
 1048  minikube 
 1049  clear
 1050  kubectl get pods
 1051  kubectl delete pod ubuntu 
 1052  clear
 1053  minikube stop
 1054  minikube start 
 1055  cd CNFS-Interposer/
 1056  ls
 1057  cd kernel-rebuild/
 1058  ls
 1059  vi install-to-minikube.sh 
 1060  ./install-to-minikube.sh  -r ~/kata-containers/
 1061  kubectl get pods
 1062  clear
 1063  CNFS-Interposer/
 1064  cd CNFS-Interposer/
 1065  ls
 1066  cd kernel
 1067  ls
 1068  cd kernel-rebuild/
 1069  ls
 1070  ./install-to-minikube.sh -r ~/kata-containers/
 1071  vi ./install-to-minikube.sh 
 1072  ./install-to-minikube.sh -r ~/kata-containers/
 1073  vi ./install-to-minikube.sh 
 1074  ./install-to-minikube.sh -r ~/kata-containers/
 1075  vi ./install-to-minikube.sh 
 1076  ./install-to-minikube.sh -r ~/kata-containers/
 1077  minikube ssh 
 1078  clear
 1079  cd ~/kata-containers/tools/packaging/kata-deploy/examples/
 1080  kubectl apply -f ubuntu.yaml 
 1081  kubectl get pods
 1082  minikube ssh
 1083  kubectl get pods
 1084  kubectl exec -it ubuntu -- sh
 1085  kubectl get pods
 1086  clear
 1087  kubectl exec -it ubuntu -- sh
 1088  kubectl get pods
 1089  clear
 1090  kubectl restart 
 1091  reboot 
 1092  sudo reboot
 1093  clear
 1094  ls
 1095  minikube start 
 1096  minikube ssh 
 1097  kubectl get pods
 1098  kubectl delete pod ubuntu 
 1099  minikube ssh 
 1100  cd CNFS-Interposer/
 1101  ls
 1102  cd kernel-rebuild/
 1103  ls
 1104  ./install-to-minikube.sh -r ~/kata-containers/
 1105  minikube ssh
 1106  ls
 1107  vi ubuntu-sample.yaml 
 1108  kubectl apply -f ubuntu-sample.yaml 
 1109  kubectl get pods
 1110  ls
 1111  kubectl 
 1112  kubectl get nodes
 1113  minikube ssh
 1114  minikube kubectl -- get pods
 1115  kubectl delete pod ubuntu
 1116  kubectl get pods
 1117  minikube ssh 
 1118  kubectl get pods
 1119  clear
 1120  minikube stop
 1121  minikube start 
 1122  kubectl get pods
 1123  kubectl delete pod ubuntu 
 1124  ls
 1125  vi install-to-minikube.sh 
 1126  minikube ssh 
 1127  ./install-to-minikube.sh -r ~/kata-containers/
 1128  minikube ssh 
 1129  kubectl apply -f ubuntu-sample.yaml 
 1130  kubectl get pods
 1131  minikube ssh 
 1132  kubectl exec -it ubuntu -- sh
 1133  clear
 1134  kubectl get pods
 1135  clear
 1136  kubectl get pods
 1137  kubectl exec -it ubuntu -- sh
 1138  kubectl get pods
 1139  minikube ssh 
 1140  kubectl exec -it ubuntu -- sh
 1141  cat /demo/hi.txt
 1142  echo "Hey, how's it going?" >> /demo/hi.txt
 1143  clear
 1144  minikube 
 1145  minikube ssh
 1146  ip addr
 1147  exportfs -v
 1148  sudo exportfs -v
 1149  clear
 1150  minikube ssh
 1151  clear
 1152  minikube ssh 
 1153  ip addr
 1154  minikube shh
 1155  minikube ssh
 1156  more ~/CNFS-Interposer/kernel-rebuild/ubuntu-sample.yaml 
 1157  kubectl get pods 
 1158  clear
 1159  exportfs -v
 1160  sudo exportfs -v
 1161  ls /demo
 1162  cat /demon/hi.txt
 1163  cat /demo/hi.txt
 1164  echo "Great day" >> /demo/hi.txt
 1165  kubectl exec -it ubuntu -- sh
 1166  kubectl get pods
 1167  kubectl exec -it ubuntu -- sh
 1168  clear
 1169  ls
 1170  cd CNFS-Interposer/
 1171  cd kernel-rebuild/
 1172  git branch
 1173  vi install-to-minikube.sh 
 1174  history >> 'raw_bash_history.sh"
 1175  history >> 'raw_bash_history.sh'
