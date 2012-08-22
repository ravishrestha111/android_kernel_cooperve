#!/bin/bash

export PATH=$PATH:/home/rafael/buildroot-2012.05/output/host/usr/bin
export CROSS_COMPILE=arm-linux-
export CC=arm-linux-gcc
export CXX=arm-linux-g++
export ARCH=arm

cd common

make mrproper && make bcm21553_cooperve_defconfig && make xconfig

echo "Ready to compile? Hit <Enter> to Continue or <Ctrl>+<C> to Cancel!";
sleep 1 && read

make