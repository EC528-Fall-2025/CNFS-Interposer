# qemu-system-x86_64 -accel kvm -m 4G -smp 4 -nographic -device virtio-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::22222-:22 -drive file=noble-server-cloudimg-amd64.img,format=qcow2   -drive file=seed.img,index=1,media=cdrom \
qemu-system-x86_64 -accel kvm -m 4G -smp 4 -nographic -device virtio-net,netdev=net0 -netdev bridge,id=net0,br=virbr0  -drive file=noble-server-cloudimg-amd64.img,format=qcow2   -drive file=seed.img,index=1,media=cdrom \
	-serial mon:stdio -display none
