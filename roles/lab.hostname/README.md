lab.hostname
============

This is an ansible role to change the machine hostname the machine will be
reboot if the hostname change.

This role as no clear value at that time is mainly to learn how to create
custom roles.

Requirements
------------

No requirements more than ansible itself.

Role Variables
--------------

``hostname``: wished hostname for the machine, by default it'll use the
"{{ inventory_hostname }}"

You can use all the settings from [reboot module](
https://docs.ansible.com/ansible/latest/modules/reboot_module.html?highlight=reboot)

* ``connect_timeout``:
* ``msg``: "Reboot the machine after changing its hostname"
* ``post_reboot_delay``: 0
* ``pre_reboot_delay``: 0
* ``reboot_timeout``: 600
* ``test_command``: whoami


Dependencies
------------

This role use the

* [hostname module](https://docs.ansible.com/ansible/latest/modules/hostname_module.html?highlight=hostname)
  to set the hostname.
* [reboot module](https://docs.ansible.com/ansible/latest/modules/reboot_module.html?highlight=reboot)
  to reboot the machine

Example Playbook
----------------


    - hosts: servers
      roles:
         - { role: lab.hostname, reboot_timeout: 3600, msg: "We reboot because..." }

License
-------

Apache License, Version 2.0

Author Information
------------------

* Pierre Verkest
