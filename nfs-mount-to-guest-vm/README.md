# Configure NFS (via /etc/exports) and Test Mount in a QEMU VM

This guide documents the steps used to configure an NFS server on the host, export a directory via `/etc/exports`, and mount that export inside a QEMU virtual machine. The steps are based on a recorded shell history and are presented here as a reproducible checklist with example commands.

Prerequisites
- A Linux host with sudo privileges (commands below use sudo).
- QEMU/KVM installed on the host to run the VM.
- Network connectivity between host and VM (the examples use an IP like `192.168.39.1`).

Overview
- Install and configure the NFS server on the host.
- Create and prepare an export directory (`/demo` in the examples).
- Configure `/etc/exports` and (re)export the shares.
- Boot a QEMU VM with cloud-init seed ISO and ensure it can reach the host.
- Mount the NFS export from inside the VM and validate read/write.

## 1. Install NFS server and create export directory

Run the following on the host to install the NFS server and create the export directory used in these examples:

```bash
sudo apt update
sudo apt install -y nfs-kernel-server
sudo mkdir -p /demo
```

## 2. Set ownership and add a test file

Adjust ownership of the exported directory and create a small test file:

```bash
sudo chown $USER:fall-2025-bu-cc- /demo   # adjust group as needed
echo "Hi" | sudo tee -a /demo/test.txt
sudo chmod 777 /demo/test.txt              # optional: relax permissions for quick testing
```

## 3. Configure `/etc/exports` and re-export

Edit `/etc/exports` and add an export line for the directory. Example entry (replace client/netmask or hostname as appropriate):

```
/demo *(rw,sync,no_subtree_check,fsid=0)
```

Then apply the exports and verify:

```bash
sudo exportfs -ra
sudo exportfs -v
```

## 4. Prepare and boot a QEMU VM (cloud image + seed ISO)

These steps show how a VM was prepared using an Ubuntu cloud image and a cloud-init seed ISO with simple password authentication. Adjust filenames and image versions to suit your environment.

On the host:

```bash
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
qemu-img resize noble-server-cloudimg-amd64.img 10G

# Create cloud-init seed files
touch network-config meta-data
cat > user-data <<'EOF'
#cloud-config
password: password
chpasswd:
	expire: false
ssh_pwauth: True
EOF

genisoimage -output seed.img -volid cidata -rational-rock -joliet user-data meta-data network-config

# Run the VM (example script referenced as qemu-boot-ubuntu.sh)
sudo ./qemu-boot-ubuntu.sh
```

Notes on networking: you may need to configure a bridge for QEMU (e.g., `/etc/qemu/bridge.conf` and related bridge setup). See the host's network/bridge configuration and adjust the VM launch script accordingly so the VM is on the same network as the host or otherwise routable to the host's IP.

## 5. Mount the NFS export inside the VM

On the VM, create a mount point and mount the NFS export. The example uses NFSv4 and the host IP `192.168.39.1`:

```bash
sudo apt update 
sudo apt install -y nfs-common
sudo mkdir -p /media/nfs
sudo mount -t nfs -o vers=4 192.168.39.1:/demo /media/nfs
ls -l /media/nfs
cat /media/nfs/test.txt
```

To test write access from the VM:

```bash
echo "How are you?" | sudo tee -a /media/nfs/test.txt
cat /demo/test.txt   # on the host: should show the appended line
```



## 6. Notes, troubleshooting and tips

- If the VM cannot reach the host, verify the host IP and QEMU networking mode. Bridged networking or user-mode networking with port-forwarding may be necessary depending on how your VM is launched. [This guide](http://spad.uk/posts/really-simple-network-bridging-with-qemu/) is a really good reference to set up bridged networking with QEMU.

- Check exported file permissions. If the VM user can't access files, temporarily relax permissions (e.g., `chmod 777`) while debugging.
- Use `sudo exportfs -v` on the host to see the list of exported paths and allowed clients.
- If you change `/etc/exports`, always run `sudo exportfs -ra` to reload exports.
- For persistent mounts on the VM, add an entry to `/etc/fstab`:

```
192.168.39.1:/demo  /media/nfs  nfs  vers=4,defaults  0  0
```

- For production use, avoid world-writable permissions and configure appropriate users, groups, and export options (e.g., `no_root_squash` only when necessary).

## Example quick verification sequence (host -> VM)

Host:

```bash
echo "Hi" | sudo tee -a /demo/test.txt
sudo exportfs -ra
sudo exportfs -v
```

VM:

```bash
sudo mkdir -p /media/nfs
sudo mount -t nfs -o vers=4 192.168.39.1:/demo /media/nfs
cat /media/nfs/test.txt
echo "I'm also great. Have you done the homework?" | sudo tee -a /media/nfs/test.txt
```

Host (verify appended content):

```bash
cat /demo/test.txt
```

Completion
- This README converts the recorded shell history into a reproducible set of instructions for configuring and testing an NFS export from a host into a QEMU VM. If you want, I can also:
	- produce a ready-to-run `qemu-boot-ubuntu.sh` example for launching the VM with bridged networking,
	- add a sample `/etc/exports` file and explain each option in detail,
	- or create an `/etc/fstab` snippet for the VM that includes improved mount options.


