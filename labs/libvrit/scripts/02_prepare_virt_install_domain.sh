#!/bin/bash

CWD=`pwd`
thisDir=$(dirname "$0")
. "$thisDir/common.args"
. "$thisDir/lib.sh"
TMPL_DIR=$CWD/data/proxmox_template
SATA1=$TMPL_DIR/sata1.img.qcow2
SATA2=$TMPL_DIR/sata2.img.qcow2
SATA3=$TMPL_DIR/sata3.img.qcow2
SSD=$TMPL_DIR/ssd.img.qcow2
PVE_ISO=$CWD/.data/proxmox-ve.iso
FORCE_RECREATE=false

set -e

USAGE="Usage: $0 [-h]

Script to prepare virt domain (a proxmox template) to install
proxmox.

Options:
    -f           Destroy existing template and networks and recreate them
                 otherwise only create domain or networks.
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

TMPL_DOMAIN_DEF="$TMPL_DIR/$TMPL_DOMAIN_NAME-domain.xml"

if $FORCE_RECREATE; then

    echo "Remove existing domain definition..."
    rm -f $TMPL_DOMAIN_DEF

    vm_absent "$TMPL_DOMAIN_NAME" ""

    networks_absent "$NETWORKS"
fi

networks_present "$NETWORKS"

if [ -f $TMPL_DOMAIN_DEF ]; then
    echo "Virsh domain definition already exists ($TMPL_DOMAIN_DEF) do nothing !"
else
    echo "Create virsh domain definition ($TMPL_DOMAIN_DEF)..."
    virt-install --connect qemu:///system \
             --import \
             --name $TMPL_DOMAIN_NAME \
             --ram 2048 --vcpus 2 \
             --cpu host-passthrough \
             --os-type=linux \
             --os-variant=virtio26 \
             --disk path=$SSD,format=qcow2,bus=virtio \
             --disk path=$SATA1,format=qcow2,bus=virtio \
             --disk path=$SATA2,format=qcow2,bus=virtio \
             --disk path=$SATA3,format=qcow2,bus=virtio \
             --disk path=$PVE_ISO,device=cdrom \
             --network network=public_network \
             --network network=private_network \
             --vnc --noautoconsole \
             --boot cdrom,hd,menu=on \
             --print-xml > $TMPL_DOMAIN_DEF
#             --network network=failover_network \
fi

EXISTS=`sudo virsh list  --name --all | grep $TMPL_DOMAIN_NAME | wc -l`
if [ $EXISTS -eq 1 ]; then
    echo "Domain $TMPL_DOMAIN_NAME already exists. Do nothing !"
else
    echo "create virt $TMPL_DOMAIN_NAME domain (using: $TMPL_DOMAIN_DEF)..."
    sudo virsh define $TMPL_DOMAIN_DEF

    echo "start virt $TMPL_DOMAIN_NAME domain..."
    sudo virsh start $TMPL_DOMAIN_NAME

    echo "Please finish this step manually open virtmanager to install proxmox.
          Remove cdrom at the end"
fi
