#!/bin/bash
CWD=`pwd`
thisDir=$(dirname "$0")
. "$thisDir/common.args"
. "$thisDir/lib.sh"
DISK_DIR=$CWD/data/proxmox_nodes
FORCE_RECREATE=false
CREATE=true

VM_DIRS=$CWD/data/vms
VM_NAME="proxmox-infra-lab-"
VMS=5

set -e

USAGE="Usage: $0 [-h] [-n X] [-f] [-r]

Script to spawn and start proxmox vm to get the env ready to apply ansible
states

Options:
    -f           Destroy existing vm and recreate them
                 otherwise only make sure VMs are started
    -n X         Where X is the number of VMs to create
    -r           Remove only, do not create, you must also provide -f otherwise
                 nothing will happen
    -h           Show this help.
"


while getopts "frn:h" OPTION
do
    case $OPTION in
        h) echo "$USAGE";
           exit;;
        n) VMS=$OPTARG;;
        f) FORCE_RECREATE=true;;
        r) CREATE=false;;
        *) echo "Unknown parameter... ";
           echo "$USAGE";
           exit 1;;
    esac
done

echo "We are going to spawn $VMS VMs..."


# I wonder why networks are not persistent so make sure they are declared
# before running VMs

if $FORCE_RECREATE; then
    for vmid in $(seq $VMS)
    do
        VM="$VM_NAME$vmid"
        vm_absent "$VM" "--remove-all-storage"
    done

    networks_absent "$NETWORKS"
fi





if $CREATE; then
    networks_present "$NETWORKS"

    for vmid in $(seq $VMS)
    do
        VM="$VM_NAME$vmid"
        echo "cloning and/or starting VM: $VM"

        EXISTS=`sudo virsh list --name | grep $VM | wc -l`
        if [ $EXISTS -eq 1 ]; then
            echo "Domain: $VM already running. skip..."
            continue
        fi

        EXISTS=`sudo virsh list  --name --all | grep $VM | wc -l`
        if [ $EXISTS -eq 1 ]; then
            echo "Domain $VM already exists. Start it..."
            sudo virsh start $VM
        else
            echo "create $VM clonning: $TMPL_DOMAIN_NAME..."
            mkdir -p $DISK_DIR
            SSD="$DISK_DIR/$VM.ssd.img.qcow2"
            SATA1="$DISK_DIR/$VM.sata1.img.qcow2"
            SATA2="$DISK_DIR/$VM.sata2.img.qcow2"
            SATA3="$DISK_DIR/$VM.sata3.img.qcow2"


            virt-clone --connect $HYPERVISOR \
                --original $TMPL_DOMAIN_NAME \
                -f $SSD \
                -f $SATA1 \
                -f $SATA2 \
                -f $SATA3 \
                -n $VM

            sudo virsh start $VM
        fi
    done
fi

echo "VM IPs:"
virsh -c $HYPERVISOR net-dhcp-leases $PUB_NET

set +e
for vmid in $(seq $VMS)
do
    VM="$VM_NAME$vmid"
    while [[ `virsh domifaddr $VM | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | wc -l` -eq 0 ]]
    do
        echo "Waiting 5s public net interface ready on $VM (infinit loop in case never ready)..."
        sleep 5
    done
done

for vmid in $(seq $VMS)
do
    VM="$VM_NAME$vmid"
    DOM_IP=`virsh domifaddr $VM | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`
    echo "$VM:"
    echo "  ansible_host: $DOM_IP"
done
