# proxmox-infra

DevOps proxmox based infra

> **IMPORTANT**: this repo is in active development state

This repo contains Ansible roles and playbooks examples to help to spawn en
entire devOps infrastructure as detailed bellow.

Here is how this repo is organized:

```bash
.
├── labs                        # Root directory for laboratories proxmox cluster
│   ├── <labname>
│   │   ├── ansible             # Ansible directory specific to the lab (inventories)
│   │   │   ├── ansible.cfg
│   │   │   └── inventory
│   │   ├── ...
│   │   └── README.md           # Describe how to get 5 proxmox ready to use
│   ├── ...
│   └── README.md               # Helps to choose the lab that feet your needs
├── LICENSE
├── playbooks                   # Ansible playbooks
│   └── README.md
├── playbook.yml                # Toppest playbook that include all others
├── README.md                   # This Read me !
├── roles                       # Ansible roles
│   └── README.md
└── tests                       # Repo that contains BDD tests agains the given playbook and roles
    └── README.md
```

The first intent of those configuration is to run BDD tests against a lab
infrastructure and keeping consistency roles with each others.

