#!/bin/sh

STTY=$(stty -g)
stty intr ^-


qemu-system-x86_64 \
    -m 1024 \
    -kernel binaries/bzImage \
    -initrd binaries/rootfs.img \
    -append "root=/dev/ram rdinit=/sbin/init console=ttyS0 quiet kaslr" \
    -nographic \
    -serial stdio \
    -snapshot \
    -monitor /dev/null \
    -fsdev local,id=exp1,path=binaries,security_model=mapped -device virtio-9p-pci,fsdev=exp1,mount_tag=share \
    -cpu kvm64,+smep,+smap \
    -s

