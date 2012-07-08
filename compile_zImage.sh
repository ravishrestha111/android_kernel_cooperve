#!/bin/bash

if [ -f kernel-repack-MD5/03-compress-ramdisk.gz.sh ] && [ -f kernel-repack-MD5/04-creat-package.sh ]; then
	echo 'Kernel Repacker	- OK'; sleep 1
else
	echo 'Kernel Repacker	- Faill'; sleep 5; exit
fi

if [ -f toolchain/arm-eabi-4.4.3/bin/arm-eabi-gcc ]; then
	echo 'CROSS_COMPILER	- OK'; sleep 1
else
	echo 'CROSS_COMPILER	- Faill'; sleep 5; exit
fi

if [ -f common/Makefile ] && [ -f modules/Makefile ]; then
	echo 'Kernel Sources	- OK'; sleep 1
else
	echo 'Kernel Sources	- Faill'; sleep 5; exit
fi

cd kernel-repack-MD5
rm -Rf zImage kernel boot.img-kernel CWM_kernel/system/lib/modules/*.ko; clear
cd ..

mkdir logs; clear

export ARCH=arm
export SUBARCH=arm
export LOCALVERSION=-45
export CROSS_COMPILE=arm-eabi-
export PATH=$(pwd)/toolchain/arm-eabi-4.4.3/bin:$PATH

if [ -f kernel-repack-MD5/boot.img-ramdisk.cpio.gz ] || [ -f kernel-repack-MD5/boot.img-ramdisk.cpio.lzma ]; then
	if [ -f kernel-repack-MD5/boot.img-ramdisk.cpio.gz ] && [ -f kernel-repack-MD5/boot.img-ramdisk.cpio.lzma ]; then
		echo 'two ramdisk files era not supported!!!'; sleep 5; exit
	fi
	echo 'have ramdisk'; sleep 5
else
	cd kernel-repack-MD5/ && ./03-compress-ramdisk.gz.sh; rm boot.img-kernel; cd ..
fi

if [ -f kernel-repack-MD5/boot.img-ramdisk.cpio.gz ]; then
	export INITRAMFS_SOURCE=$(pwd)/kernel-repack-MD5/boot.img-ramdisk.cpio.gz
fi

if [ -f kernel-repack-MD5/boot.img-ramdisk.cpio.lzma ]; then
	export INITRAMFS_SOURCE=$(pwd)/kernel-repack-MD5/boot.img-ramdisk.cpio.lzma
fi

cd common

if [ -f .config ]; then 
	make clean
else
	cd .. && ./configure.sh && cd common
fi

make silentoldconfig && make modules zImage CONFIG_DEBUG_SECTION_MISMATCH=y -j`grep processor /proc/cpuinfo | wc -l` 2>&1 | tee ../logs/$(date +%Y%m%d-%H%M)-make.log && find . ../modules -name '*.ko' -exec cp -v {} ../kernel-repack-MD5/CWM_kernel/system/lib/modules \;

cd ..

cp ./common/arch/arm/boot/zImage ./kernel-repack-MD5/

if [ -f ./kernel-repack-MD5/zImage ]; then
	cd kernel-repack-MD5 && ./04-creat-package.sh && cd ..
else
	echo 'Compile Fail'
fi

sleep 5
