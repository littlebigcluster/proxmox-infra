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
│   │   ├── lab_inventory       # Ansible inventory related to the lab
│   │   │   ├── group_vars
│   │   │   ├── host_vars
│   │   │   ├── ...
│   │   │   └── hosts
│   │   ├── ...                 # Other files to get lab working
│   │   └── README.md           # Describe how to get 5 proxmox ready to use
│   ├── ...
│   └── README.md               # Helps to choose the lab that feet your needs
├── LICENSE
├── playbooks                   # Ansible playbooks
│   └── README.md
├── playbook.yml                # Toppest playbook that include all others
├── README.md                   # This Read me !
├── galaxy-roles                # contrib roles installed with ansible-galaxy
├── roles                       # Ansible roles
│   └── README.md
├── roles-requirements.yml      # Ansible contrib roles to get from ansible galaxy
└── tests                       # Repo that contains BDD tests agains the given playbook and roles
    └── README.md
```

The first intent of those configuration is to run BDD tests against a lab
infrastructure and keeping consistency roles with each others.

# How to give a try using a lab

- [ ] Get a lab running following instructions of the [lab you have chosen](
  labs/README.md)
- [ ] install or update roles using roles-requirements.yml

pip install -r requirements.txt
ansible-galaxy install -r roles-requirements.yml
ansible-playbook -i inventory -D playbooks/proxmox.yml
ln -s labs/libvrit/ansible_lab/playbooks/ lab_playbook
ln -s labs/libvrit/ansible_lab/inventory/ .
rm cachedir/*
ansible all  -i inventory -m setup
ansible-inventory -i inventory --graph
ansible-playbook -i inventory -D lab_playbook/playbook_init_lab.yml

