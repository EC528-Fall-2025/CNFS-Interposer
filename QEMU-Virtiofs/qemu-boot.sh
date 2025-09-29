qemu-system-x86_64 -accel kvm -m 4G -smp 4 -nographic -device virtio-net,netdev=net0 -netdev user,id=net0,hostfwd=tcp::22222-:22 -drive file=image.qcow2,format=qcow2 -drive file=config.img,format=raw \
	-chardev socket,id=char0,path=/tmp/vhostqemu \
	-device vhost-user-fs-pci,queue-size=1024,chardev=char0,tag=myfs \
	-object memory-backend-file,id=mem,size=4G,mem-path=/dev/shm,share=on -numa node,memdev=mem \
