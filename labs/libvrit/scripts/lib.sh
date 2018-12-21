#!/bin/bash

# Make sure given networks are present and installed
# xml file should be present localy for given networks
# $1 - nets: a string with  a list of networks space separator (ie: "net1 net2")
function networks_present() {
    nets=$1
    for NET in $nets
    do
        NET_DEF="$NET.xml"
        EXISTS=`sudo virsh net-list --name | grep $NET | wc -l`
        if [ $EXISTS -eq 1 ]; then
            echo "Network $NET already present. Do nothing"
        else
            echo "create $NET network"
            sudo virsh net-create $NET_DEF
        fi
    done
}

# Make sure given networks are absent
# $1 - nets: a string with  a list of networks space separator (ie: "net1 net2")
function networks_absent() {
    nets=$1
    echo "Remove existing networks if present..."
    for NET in $nets
    do
        EXISTS=`sudo virsh net-list --name | grep $NET | wc -l`
        if [ $EXISTS -eq 1 ]; then
            echo "Removing Network: $NET..."
            sudo virsh net-destroy $NET
        fi
    done
}

# make sure a vm is completely removed
# $1 - domain: remov
# $2 - undefine_args: additionnal args to give to undefine (likes
#      --remove-all-storage)
function vm_absent() {
    domain=$1
    undefine_args=$2

    echo "Remove domain: $domain if present..."
    EXISTS=`sudo virsh list --name | grep $domain | wc -l`
    if [ $EXISTS -eq 1 ]; then
        echo "Domain $domain running. Sopping..."
        sudo virsh destroy $domain
    fi
    EXISTS=`sudo virsh list --name --all | grep $domain | wc -l`
    if [ $EXISTS -eq 1 ]; then
        echo "Domain $domain were present. Removing with args: $undefine_args..."
        sudo virsh undefine $domain $undefine_args
    fi
}


# Make sure vm exists, if not exit whith error
# if present and not running, try to start it
function vm_running() {

    VM=$1
    EXISTS=`sudo virsh list --name | grep $VM | wc -l`
    if [ $EXISTS -eq 1 ]; then
        echo "Domain $VM already running. Do nothing"
    else
        EXISTS=`sudo virsh list  --name --all | grep $VM | wc -l`
        if [ $EXISTS -eq 1 ]; then
            echo "Domain $VM already exists. Start it..."
            sudo virsh start $VM
        else
            echo "Domaint $VM not found can't start it"
            exit 1
        fi
    fi

}