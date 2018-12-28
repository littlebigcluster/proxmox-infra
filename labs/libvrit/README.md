# Proxmox lab using libvirt

[libvirt](https://libvirt.org/) is a toolkit to manage visualization
platforms that support multiple hypervisors: KVM, VirtualBox, OpenVZ, LXC...

This libvirt lab provide some shell scripts to get a working 5 proxmox
server based on libvirt. The intent of this lab is to test configuration
recipe on a lab without any production environment but really close to
what we expected in production.


## Caveats

The intent of this lab is not for production ready as main goals
is to tested feature in a test environment before deploy in production.


## Infra and features

In this section you will learn what infrastructure spawned by this lab and
features provided.

Once you will follow the usage section you'll get

- 5 proxmox servers installed that simulate a light version of
  [core-4-m-sata](https://www.online.net/en/server-dedicated/core-4-m-sata)
  servers with following settings in produciton:
  * **RAM**: 192GB => 2GB per VM in this lab
  * **CPU**: 2x Intel® Xeon® E5 2640 v4  => 2 vcpu
  * **Sata Storage**: 3 x 6TB => 3 x 6GB per VM in this lab
    (iso image with dynamic size)
  * **SSD Storage**: one extra 500GB SSD => 50 GB per VM in this lab
    * *pve-swap*: 24G (1/8 RAM) => 4G
    * *pve-root*: 30G           => ~12G
    * *pve-data*: ~387G         => ~25G

To install that we provide some tools that are covered in detail in the next
section, we aims to make them idempotent:

- ``scripts/00_download_proxmox_image.sh`` is a script to download a proxmox iso
  image if not present locally
- ``scripts/01_create_virtual_disks.sh`` create qcow2 virtual disk image that
  will be used by the core-4-m proxmox libvirt template.
- ``scripts/02_prepare_virt_install_domain.sh`` create a template machine and
  networks ``core-4-m-proxmox-template`` if not already created and install
  proxmox inside
- ``scripts/03_prepare_template.sh`` prepare the template server
  ``core-4-m-proxmox-template`` (like using dhcp instead static ip)
- ``scripts/04_spwan_proxmox_servers.sh`` clone the template proxmox server
  ``core-4-m-proxmox-template`` to create 5 proxmox servers if not already
  present with following names: ``proxmox-infra-lab-[1-5]``


## Usage

> **Note**: This documentation was tested on Debian 9 (stretch)

### Dependencies

This lab require some dependencies

* add [salt repo](https://repo.saltstack.com/#debian) and update your indexes

* install dependencies:

  ```bash
  sudo apt install salt-cloud libvirt-daemon salt-master \
        libvirt-clients virt-manager git-lfs sshpass
  ```

* enable [nested virtualization](https://stafwag.github.io/blog/blog/2018/06/04/nested-virtualization-in-kvm/)
  to be able to launch kvm inside virtualized proxmox (make sure to stop all
  your kvms):

  ```bash
  ~/$ cat /sys/module/kvm_intel/parameters/nested
  N
  ~/$ sudo virsh list
  [sudo] Mot de passe de pverkest : 
   Id    Name                           State
  ----------------------------------------------------

  ~/$ sudo modprobe -r kvm_intel
  ~/$ sudo modprobe kvm_intel nested=1
  ~/$ cat /sys/module/kvm_intel/parameters/nested
  Y

  # later in a proxmox vm, make sure you can use kvm by running
  cat /proc/cpuinfo | grep  -i -E "vmx|svm"
  ```

## Checklist

This checklist is the list of things to do to install the lab with
provided scripts to get 5 proxmox servers

- [ ] Setup libvirt template: Start from the beginning if you want to download
  a new proxmox installer or at least recreate core-4-m proxmox templates:
  - [ ] You can cleanup ``.data/*`` and ``data/*`` directories according your
        needs
  - [ ] download proxmox iso installer
        (``scripts/00_download_proxmox_image.sh``)
  - [ ] prepare qcow2 disk images (``scripts/01_create_vritual_disks.sh``)
  - [ ] Prepare virt domain and create the template machine (
        ``scripts/02_prepare_virt_install_domain.sh``)
  - [ ] follow proxmox setup using virt-manager to get the proxmox installer:
    - [ ] click on "I agree" to accept the proxmox licence
    - [ ] choose ``/dev/vda (50Gb)`` target harddisk and click on option to choose:
        - [ ] fs ext4
        - [ ] hgsize 50
        - [ ] pve-swap: 4
        - [ ] maxroot: 12
    - [ ] choose a time zone
    - [ ] setup password: ``abc123``, email: mail@example.org
    - [ ] manage network interface (ens3 using public network 192.168.125.x):
        - [ ] hostname (FQDN): core-4-m-proxmox-template.lab
        - [ ] IP Address: 192.168.123.133 (this is hardcoded address in script used to switch to dhcp)
        - [ ] Netmask: 255.255.255.0
        - [ ] Gateway: 192.168.125.1
        - [ ] DNS Server: 8.8.8.8 (Google ones, you may choose others acording your preferences)
    - [ ] click the install button
    - [ ] remove the cdrom (you may need to reboot to be able to deconnect the device)
    - [ ] reboot the freshly template vm
    - [ ] make sur you can connect over ssh and on the web uri:
        - https://192.168.125.133:8006 (pam login root/abc123)
        - ssh root@192.168.125.133 (password abc123)
  - [ ] Setup template machine using ``scripts/03_prepare_template.sh``

- [ ] Spawn 5 proxmox servers and make them running (
      ``scripts/04_spwan_proxmox_servers.sh``
- [ ] Ansible config:
   - [ ] make sure to have ansible installed (on your laptop or a venv)
   - [ ] link the labs/libvirt/ansible/inventory directory to the top of this
     repo

- [ ] Run ansible playbooks

- [ ] Run tests

- [ ] cleanup environement


## Documentation

Here we will explain how to setup your lab.

To get more details on each scripts you can use the help option on it ``-h``.

All scripts must be launch from the root directory.


### scripts/00_download_proxmox_image.sh

This script download a proxmox iso image if not present locally. If you want
to get a new one remove the it manually:

```bash
rm .data/proxmox-ve.iso
```

### scripts/01_create_vritual_disks.sh

We are creating virtual disk image to simulate SATA and SSD disks. This
script create images only if they don't exists. You can use ``-f`` option
to remove existing disk images and recreate new ones.

### scripts/02_prepare_virt_install_domain.sh

Using this script you'll prepare libvirt template machine that will be used
to clone and spawn other proxmox machine to create the cluster.

### scripts/03_prepare_template.sh

This script start the template to make it ready to clone.

### scripts/04_spwan_proxmox_servers.sh

This script is used to clone the template, by default it will create 5 VMs.
using ``-f`` that will remove all VMs and re-create new ones from the template.
using ``-r`` (with ``-f``) it will remove VMs and do not create new ones wich
is nice to cleanup thems

## TODO

- [x] A script to create libvirt template using proxmox iso
- [x] A script to prepare disk image for proxmox template
- [x] Prepare virt domain and create the template machine
- [x] duplicate template to spwan 5 proxmox nodes
- [x] init config on template vm to avoid static ip
- [ ] ansible inventory script
