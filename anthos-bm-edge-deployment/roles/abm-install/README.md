Role Name
=========

This role installs Anthos Bare Metal onto a "ready" machine or VM. The role installs a user (el-gato) for the installation, all of the key management for the installation, google service accounts, ABM configuration, pre-flight checks and creation of clusters

Requirements
------------

DNS Python library is required, please run:

```bash
pip install dnspython
```

Role Variables
--------------

See `vars/main.yml` for information

Tags
--------------

Tasks associated with:
* abm-install - all tasks in the role
* abm-ssh - SSH keys and AMB installation user
* abm-once - Creation of the Google Service Accounts
* abm-config - Configuration for the ABM Cluster
* abm-create - Cluster creation