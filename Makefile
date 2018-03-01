CC := clang
CFLAGS := -Wall -static 
EXPLOIT_NAME=cve-2017-5123

.PHONY: initramfs exploit run clean

all: run

initramfs:
	cd filesystem && find . | cpio -o --format=newc --owner=root:root > ../binaries/rootfs.img

exploit:
	$(CC) -o binaries/$(EXPLOIT_NAME) $(EXPLOIT_NAME).c $(CFLAGS)

run: exploit initramfs
	qemu-system-x86_64 \
    	-m 1024 \
    	-kernel binaries/bzImage \
    	-initrd binaries/rootfs.img \
    	-append "root=/dev/ram rdinit=/sbin/init console=ttyS0 quiet kaslr" \
    	-nographic \
    	-serial stdio \
    	-monitor /dev/null \
    	-fsdev local,id=exp1,path=binaries,security_model=mapped -device virtio-9p-pci,fsdev=exp1,mount_tag=share \
    	-cpu kvm64,+smep,+smap \
    	-s

clean:
	rm $(EXPLOIT_NAME)
