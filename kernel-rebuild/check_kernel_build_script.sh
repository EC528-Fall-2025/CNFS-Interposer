    1  clear
    2  ls
    3  clear
    4  wget https://go.dev/dl/go1.25.4.linux-amd64.tar.gz
    5  clear
    6  tar -C /usr/local -xzf go1.25.4.linux-amd64.tar.gz 
    7  sudo tar -C /usr/local -xzf go1.25.4.linux-amd64.tar.gz 
    8  export PATH=$PATH:/usr/local/go/bin
    9  go version 
   10  echo 'export PATH=$PATH:/usr/local/go/bin/' >> ~/.bashrc
   11  more .bashrc
   12  clear
   13  source ~/.bashrc
   14  go version 
   15  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   16  less .bashrc 
   17  clear
   18  rustc --version 
   19  source ~/.bashrc
   20  rustc --version 
   21  clear
   22  git clone https://github.com/kata-containers/kata-containers.git
   23  pushd kata-containers/src/runtime 
   24  make 
   25  ls
   26  ls /home
   27  cd kata-containers
   28  ls
   29  sudo apt install git make
   30  pushd src/runtime
   31  make 
   32  make clean
   33  clear
   34  go
   35  go env
   36  export go env
   37  echo $GOPATH
   38  export
   39  set -a 
   40  go env | source
   41  echo `go env`
   42  echo `go env` | source
   43  go
   44  clear
   45  ls
   46  rustc
   47  clear
   48  make 
   49  clear
   50  sudo apt install qemu-system-x86_64
   51  sudo apt search qemu-system
   52  sudo apt install qmeu-system
   53  sudo apt update
   54  sudo apt install qemu-system
   55  clear
   56  echo `go env` 
   57  go env
   58  export GOPATH='/users/rakin000/go'
   59  make
   60  sudo -E "PATH=$PATH" make install 
   61  sudo mkdir -p /etc/kata-containers/
   62  sudo install -o root -g root -m 0640 /usr/share/defaults/kata-containers/configuration.toml /etc/kata-containers
   63  popd
   64  ll /
   65  ll /etc/kata-containers/
   66  ll /usr/share/defaults/kata-containers/
   67  vi /usr/share/defaults/
   68  vi /etc/kata-containers/configuration.toml 
   69  kataruntime
   70  kata-runtime
   71  ll tools/packaging/kernel/configs/fragments/common/
   72  vi tools/packaging/kernel/configs/fragments/common/fs.conf
   73  vi tools/packaging/kernel/configs/fragments/common/base.conf
   74  ll tools/packaging/kernel/configs/fragments/common/confidential_containers/
   75  ll tools/packaging/kernel/
   76  more tools/packaging/kernel/README.md
   77  ll $GOPATH/src
   78  cd  tools/packaging/kernel/
   79  ls
   80  cat kata_config_version 
   81  ./build-kernel.sh 
   82  ./build-kernel.sh build
   83  ./build-kernel.sh -d seup
   84  ./build-kernel.sh -d setup
   85  yq
   86  go
   87  go yq
   88  more README.md 
   89  go install github.com/mikefarah/yq/v4@latest
   90  yq
   91  ./build-kernel.sh -d setup
   92  ./build-kernel.sh build
   93  grep -R "_sudo" ~/.bashrc
   94  grep -R "_sudo" ~/.profile
   95  grep -R "_sudo" ~/.bash_aliases
   96  grep -R "_sudo" ~/.bash_login
   97  type _sudo
   98  vi build-kernel.sh 
   99  more /etc/kata-containers/configuration.toml 
  100  clear
  101  exit
  102  ls
  103  kata-runtime
  104  clear
  105  vi /etc/kata-containers/configuration.toml 
  106  ll /usr/share/
  107* 
  108  vi /etc/kata-containers/configuration.toml 
  109  vi /usr/share/kata-containters
  110  ll /usr/share/kata*
  111  ll /usr/share/defaults/kata-containers/
  112  kata-runtime
  113  kata-runtime --config
  114  cd kata-containers/tools/packaging/kernel
  115  ls
  116  clear
  117  ls
  118  ./build-kernel.sh 
  119  cd /usr/share
  120  ls
  121  cd kata-
  122  ll kata*
  123  cd ~/kata-containers/
  124  ls
  125  cd tools/
  126  ls
  127  cd kernl
  128  cd kernell
  129  cd kernel
  130  clear
  131  ls
  132  cd packaging/kernel/l
  133  cd packaging/kernel/
  134  ls
  135  ./build-kernel.sh
  136  ./build-kernel.sh -h
  137  ./build-kernel.sh -v 5.10.25 -g nvidia -f -d setup
  138  cd ..
  139  git checkout 3.22.0
  140  clear
  141  cd tools/
  142  cd packaging/
  143  cd kernel/
  144  ls
  145  ./build-kernel.sh -v 5.10.25 -g nvidia -f -d setup
  146  ls configs
  147  ll configs/fragments/
  148  ll configs/fragments/x86_64/
  149  vi build-kernel.sh 
  150  die
  151  vi build-kernel.sh 
  152  clear
  153  ./build-kernel.sh -v 5.10.25 -f -d setup
  154  ./build-kernel.sh -v 5.10.25 -f -d setup 2> error.error
  155  vi error.error 
  156  which flex
  157  sudo apt install flex
  158  clear
  159  ./build-kernel.sh -v 5.10.25 -f -d setup
  160  flex
  161  sudo apt install bison
  162  clear
  163  sudo apt update
  164  clear
  165  ./build-kernel.sh -v 5.10.25 -f -d setup
  166  vi build-kernel.sh 
  167  ls
  168  ls configs/
  169  ls configs/fragments/
  170  ls configs/fragments/x86_64/
  171  ll configs/fragments/x86_64/
  172  vi configs/fragments/x86_64/.config 
  173  clear
  174  vi build-kernel.sh 
  175  ./build-kernel.sh -v 6.1.13 -f -d setup
  176  ./build-kernel.sh build
  177  go install github.com/mikefarah/yq/v4@latest
  178  yq
  179  ./build-kernel.sh build
  180  ls
  181  ls ~/
  182  ls ~/go
  183  ls ~/go/bin
  184  vi ~/.source
  185  vi ~/.bashrc
  186  ls /usr/local/go/
  187  ls /usr/local/go/bin
  188  vi ~/.bashrc
  189  echo $HOME
  190  source ~/.bashrc
  191  yq
  192  which yq
  193  echo $PATH
  194  vi ~/.bashrc
  195  source ~/.bashrc
  196  yq
  197  CLEAR
  198  ./build-kernel.sh build
  199  ./build-kernel.sh setup
  200  ./build-kernel.sh build
  201  sudo apt install libelf
  202  sudo apt install libelf-dev
  203  clear
  204  ./build-kernel.sh build
  205  sudo ./build-kernel.sh install
  206  yq
  207  sudo ./build-kernel.sh install
  208  sudo -E "PATH=$PATH" ./build-kernel.sh install
  209  history >> check_kernel_build_script.sh
