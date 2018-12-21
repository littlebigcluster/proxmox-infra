# LABs


Here are different ways to get 5 proxmox vm ready to run on your laptop
to run tests, or have a trie of the solution before order some physical
server to your favorite hosted providers.

According your convenience and your environment you may choose one of the
following solution:

* [libvirt](libvirt/README.md): tested on debian stretch, use libvirt through
  bash scripts to get 5 servers up and running before play states in the
  main repo.


# Lab requirement

If you wan't to create a lab with other technologies you are welcome

Each labs should provide:

* A ``README.md`` that exaplain how to obtain 5 proxmox server ready to applay
  provide playbook
* A ``lab_inventory`` directory with all the inventory related to
  that lab.
