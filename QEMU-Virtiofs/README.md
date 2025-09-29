# Virtiofs with QEMU


## Instructions

### Image Configuration

Replace public ssh key and password in user-data.yaml. With a public ssh key and a sha512 of a password. (private key need later for ssh).
Then create seed image. You may have to install cloud-localds:
```
$ cloud-localds config.img user-data.yaml meta-data.yaml
```

### QEMU setup using qemu-boot.sh
1. Install QEMU
```
$ sudo apt install qemu-system
```
2. Get a cloud image, place it in the same directory as qemu-boot.sh
Download an [Ubuntu 24.04 image] in QCow2 format(https://cloud-images.ubuntu.com/noble/current/).
"noble-server-cloudimg-amd64.img" for x86

3. Rename and resize
```
$ mv <image_name> image.qcow2 
$ qemu-img resize image.qcow2 10G
```
4. Run boot script
```
$ ./qemu-boot.sh
```

### Virtiofs setup
Follow [these instructions](https://virtio-fs.gitlab.io/howto-qemu.html).
You will at least have to:
1. Install Virtiofs daemon and QEMU
```
$ sudo apt install virtiofsd 
```
2. Start the Virtiofs daemon. virtiofs.sh includes a path to the directory on the host that you want to share in "source". Make sure this path exists.
```
$ ./virtiofs.sh
```
### ssh into QEMU VM 
```
$ ssh alexh@localhost -p 22222 -i root.id_rsa
```
where: root.id_rsa is the path to your private ssh key that pairs with the public key in user-data.yaml.

4. From the guest, issue the mount command
``` 
$ mount -t virtiofs myfs /mnt
```
