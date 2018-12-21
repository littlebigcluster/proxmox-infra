#!/bin/sh

PVE_ISO_URI="https://www.proxmox.com/en/downloads?task=callelement&format=raw&item_id=422&element=f85c494b-2b32-4109-b8c1-083cca2b7db6&method=download&args[0]=b90ca961a113e916b7f635085945efa8"
PVE_ISO_NAME="proxmox-ve.iso"
PVE_LOCAL=".data/$PVE_ISO_NAME"

set -e


USAGE="Usage: $0 [-h]

Script to downlaod proxmox ISO image in order to prepare
libvirt template that will be used by salt cloud.

If proxmox image is there it won't be downloaded again

Options:
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

PVE_SHA256SUMS=ba9721a2cfedac5567ab6aeff2b63d0c15bc46a0f8a40bc39dfb9d067bc6ef49


if [ -f "$PVE_LOCAL" ]; then
    echo "$PVE_LOCAL already exists! Remove it manually if you want a new one."
else
    echo "Downlaod proxmox image from $PVE_ISO_URI"
    wget -O $PVE_LOCAL $PVE_ISO_URI
fi

echo "In any case we make sure iso image as expected sha256"
echo "$PVE_SHA256SUMS $PVE_LOCAL" > "$PVE_LOCAL.sha256"
sha256sum -c "$PVE_LOCAL.sha256"
