#!/bin/sh

set -e

SATA_SIZE=${SATA_SIZE:-6G}
SSD_SIZE=${SSD_SIZE:-50G}
FORCE_RECREATE=false
ROOT_DIR=data/proxmox_template
SATA1=$ROOT_DIR/sata1.img.qcow2
SATA2=$ROOT_DIR/sata2.img.qcow2
SATA3=$ROOT_DIR/sata3.img.qcow2
SSD=$ROOT_DIR/ssd.img.qcow2


USAGE="Usage: $0 [-h]

Script to create qcow2 disk images for the libvirt
template.

Options:
    -f           Force recreate qcow2 disk image even they already exists
    -h           Show this help.
"


while getopts "fh" OPTION
do
    case $OPTION in
        h) echo "$USAGE";
           exit;;
        f) FORCE_RECREATE=true;;
        *) echo "Unknown parameter... ";
           echo "$USAGE";
           exit 1;;
    esac
done

mkdir -p $ROOT_DIR

if $FORCE_RECREATE; then
    echo "Remove existing proxmox template disk (.qcow2)..."
    rm -f $SATA1
    rm -f $SATA2
    rm -f $SATA3
    rm -f $SSD
fi

if [ -f $SATA1 ]; then
    echo "Virtual disk $SATA1 alreday exists, do nothing"
else
    echo "Create virtual disk $SATA1 ($SATA_SIZE)..."
    qemu-img create -f qcow2 $SATA1 $SATA_SIZE
fi

if [ -f $SATA2 ]; then
    echo "Virtual disk $SATA2 alreday exists, do nothing"
else
    echo "Create virtual disk $SATA2 ($SATA_SIZE)..."
    qemu-img create -f qcow2 $SATA2 $SATA_SIZE
fi

if [ -f $SATA3 ]; then
    echo "Virtual disk $SATA3 alreday exists, do nothing"
else
    echo "Create virtual disk $SATA3 ($SATA_SIZE)..."
    qemu-img create -f qcow2 $SATA3 $SATA_SIZE
fi


if [ -f $SSD ]; then
    echo "Virtual disk $SSD alreday exists, do nothing"
else
    echo "Create virdual disk $SSD ($SSD_SIZE)..."
    qemu-img create -f qcow2 $SSD $SSD_SIZE
fi