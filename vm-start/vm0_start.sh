
qemu-system-aarch64 \
	-netdev tap,id=net1,ifname=tap1,script=/etc/qemu-ifup \
	-device virtio-net-device,netdev=net1,mac=52:54:00:12:34:57 \
	-M virt,gic_version=host,accel=kvm \
	-cpu host \
	-nographic -smp 1 \
	-m 4096  \
	-kernel Image \
	-append "root=/dev/nfs rw rootwait ip=dhcp nfsroot=10.30.5.120:/home/wangyazhou/share/debian/domU,nolock,proto=tcp,nfsvers=4" \
	-device vfio-axi-dma,host=80000000.dma
