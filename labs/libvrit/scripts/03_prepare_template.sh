#!/bin/bash
CWD=`pwd`
thisDir=$(dirname "$0")
. "$thisDir/common.args"
. "$thisDir/lib.sh"

TEMPLATE_IP=192.168.125.133
TEMPLATE_LOGIN=root
TEMPLATE_PWD=abc123
NET_IFACES_FILE="$CWD/interfaces"

set -e

USAGE="Usage: $0 [-h]

Script to setup template vm with correct default network config, and updated
system

Options:
    -f           Destroy existing vm and recreate them
                 otherwise only make sure VMs are started
    -n X         Where X is the number of VMs to create
    -r           Remove only, do not create, you must also provide -f otherwise
                 nothing will happen
    -h           Show this help.
"


while getopts "h" OPTION
do
    case $OPTION in
        h) echo "$USAGE";
           exit;;
        *) echo "Unknown parameter... ";
           echo "$USAGE";
           exit 1;;
    esac
done


vm_running $TMPL_DOMAIN_NAME

# Let a chance to the vm to start, we may improve to try connection
# about 10s and raise an exception if not possible
echo "let a chance to the vm to startup in 5s"
sleep 5

# use dhcp instead static ips
echo "Coping $NET_IFACES_FILE to $TEMPLATE_LOGIN@$TEMPLATE_IP:/etc/network/interfaces"
sshpass -p "$TEMPLATE_PWD" scp \
    "$NET_IFACES_FILE" \
    "$TEMPLATE_LOGIN@$TEMPLATE_IP:/etc/network/interfaces"

sudo virsh shutdown $TMPL_DOMAIN_NAME
