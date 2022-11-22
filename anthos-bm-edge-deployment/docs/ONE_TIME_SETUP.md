# One-time setup

Each of these segments are required to setup both the **Provisioning machine** and the **Target machine(s)**.

---

TOC: [Provision Target Machines](#provision-target-machines) | [ Access Target Machines ](#access-target-machines)

---

## Establishing a Baseline

[Target machines](../README.md#terms-to-know) are the physical or cloud machines that will be running the solution. The one-time installation process is necessary to establish a baseline that is common between both the Cloud and Physical machines. This baseline is then used by Ansible playbooks to provision a target machine.

These steps will need to be followed for the first installation, or any subsquent refreshing of the installation (ie, wiping and starting from scratch)

In this "one-time-setup", you will perform four primary goals:

1. Setup a bootable USB stick<sup>†</sup> containing Ubuntu 20.04 LTS
1. Setup SSH keys to allow passwordless access to the remote machine
1. Setup the **provisioning** machine with Ansible and Ansible dependencies
1. Setup inventory files

<sup>†</sup> PXE is out of scope, but follows similar concept.

## Goal 1 - Provision target machine(s)

### Step 1 - Create asymetric keys for SSH

1. Create (or use an existing) asymetric key-pair to SSH into all inventory. NOTE: the names of the keys below are defaults, so if you want to use different names, you will need to adjust ENV variables to match (not recommended).

    > :warning: **DO NOT** use a passphrase, just hit [enter]

    ```bash
    # SSH key-pair for physical machines
    ssh-keygen -t ed25519 -f ~/.ssh/nucs
    ```
    ```bash
    # SSH key-pair for Cloud machines
    ssh-keygen -t ed25519 -f ~/.ssh/cnucs-cloud
    ```

### Step 2 - Create and Provision Hardware or Cloud machines

* Hardware Option - [this document details the provisioning of hardware](HARDWARE_PROVISION.md)
* Cloud Option - [this document details the creation and baseline installation of GCE cloud machines](CLOUD_PROVISION.md)


## Goal 2 - Establishing Passwordless SSH

> NOTE: Some steps are required for both target types unless indicated.

The following are performed from the **provisioning machine**.

1. Ping each machine (note, if failures, try once again before getting nervous). Also, see note below about `.lan` or `.localdomain` suffix that some routers automatically append for hostname resolution.
    > NOTE: At this point, `cnuc` has not been setup for hostname references.

    > NOTE: First time run will prompt you to accept the new `fingerprint`.  Please type "yes" when prompted. If there is an SSH error, please see [Troubleshooting Inventory](#troubleshooting-inventory). Most of the time, you can run the suggested `ssh-keygen` command (ie: `ssh-keygen -f "/home/<user>/.ssh/known_hosts" -R "nuc-1"`) to remove the old fingerprint

    ```bash
    # Set however many machines you have provisioned. This example is 3
    export GCE_COUNT=3
    for i in `seq $GCE_COUNT`; do
        HOSTNAME="nuc-$i" # chose 'cnuc' or 'nuc' according to your scenario
        ssh abm-admin@${HOSTNAME} 'ping -c 3 google.com'
    done
    ```

1. Setup SSH for passwordless access using SSH Configuration
    * Create or add configuration to your `~/.ssh/config` file

    #### Physical SSH Config

    ```yaml
    ### Host configuration for all physical nucs
    Host nuc-*
        User abm-admin
        StrictHostKeyChecking no
        IdentityFile ~/.ssh/nucs
    ```

    > NOTE: The SSH key MUST be permissions `600` (rw owner only) and the config must be minimally `644` (rw owner, read other), but `600` is ok too

    #### Cloud SSH Config (optional)

    > NOTE: The ansible playbooks use a Google Cloud plugin to [dynamically build the inventory file](#cloud-inventory-file), so SSH access isn't required, but it is very helpful for debugging and it is required (for now) when running `kubectl` commands on the cluster. There are a few options for setting up SSH to `cnuc` machines.

    * Option 1 - Use the `gcloud compute ssh abm-admin@<IP of machine>`. You only need to know the IP of the machine (see [Verifying Inventory Status](#verifying-inventory-status) for an easy way to find CNUC->IP listing)

    * Option 2 - Use SSH config just like physical NUCs. Any hostname references in the `~/.ssh/config` file need to be translated in `/etc/hosts` with the IP address to `cnuc-x`. See [cnuc Hostname Setup](#cnuc-hostname-setup) for scripts that assist in this process.

    ```yaml
    ### Host configuration for cnucs
    Host cnuc-*
        User <user>
        StrictHostKeyChecking no
        IdentityFile ~/.ssh/cnucs-cloud
    ```

1. Done! If you can SSH into all target machines without using a password or referencing an identity file, then you're ready to setup Ansible.


## Goal 3 - Setup the Provisioning machine

Setting up the machine has 4 steps, setting up python, instaling dependencies, provisioning a Google Service Account, and establishing some required environment variables.

### Step 1 - Setup Python 3
1. Provisioning machine needs to have Python 3.x (3.7+ is recommended)

    1. Test python version:

        ```bash
        python --version
        ```

1. Sometimes systems have `python` and `python3`. Reference https://docs.ansible.com/ansible/latest/reference_appendices/python_3_support.html for reference on how to support `python3` (often adding `ansible_python_interpreter=/usr/bin/python3` to the Ansible config is required, along with all depenedencies installed with `pip3`)

### Step 2 - Install all python depencencies
1. Run this if you don't care about precise used/unused libraries
    ```bash
    pip install --upgrade pip # upgrade pip just-in-case
    pip install ansible
    pip install dnspython
    pip install requests
    pip install google-auth
    ```

### Step 3 - Setting up GCP Service Account for provisioning

Both `physical` and `cloud` installations use a GSA (`target-machine-gsa@<project-id>.iam.gserviceaccount.com`) to run commands inside the **target machines**. The installation process needs keys to securely pass (via Secrets Manager) the keys to each target machine. Follow the steps below to generate (or update) the GSA and create or re-create a set of keys for use.

1. Create a service account key and set an environment varaible (`LOCAL_GSA_FILE`) to that location

    1. A helper script is provided to generate, provision with IAM roles and download the key

        ```bash
        # Follow prompts
        ./scripts/create-primary-gsa.sh

        export LOCAL_GSA_FILE="./remote-gsa-key.json"
        ```

    > NOTE: Add the `export LOCAL_GSA_FILE=...` line to `.bashrc` or `.envrc` (if using `direnv`) so new shells can establish this required environment variable

### Step 4 - Required environment variables

> RECOMMENDATION: use [direnv](https://direnv.net/) to manage local environment variables per project. You would then store each of the below variables in a `.envrc` file at the root of the project.

| Environment Variable | Required | Description | Default Value |
|:---------------------|:--------:|:------------|:-------------:|
| LOCAL_GSA_FILE       |  Y       |  Google Service Account key to a GSA that is used to provision and activate all Google-based services (all `gcloud` commands) from inside the Target machine(s) | N/A |
| PROJECT_ID           |  N       |  Google Project ID to put clusters, Service Accounts and API services into | gcloud config |
| SSH_PUB_KEY_LOCATION |  N       |  SSH public key location for Ansible | `$HOME/.ssh/cnucs-cloud.pub` |
| ZONE                 |  N       |  Google default zone | gcloud config  |
| SCM_TOKEN_USER       |  Y       |  Git repo token user/name | none  |
| SCM_TOKEN_TOKEN      |  Y       |  Git repo token string | none  |

GSA Permissions should include:
- Editor (roles/editor) or Owner (roles/owner)
- Storage Object Viewer (roles/storage.objectViewer)
- Project IAM Admin (roles/resourcemanager.projectIamAdmin)
- Secret Manager Admin (roles/secretmanager.admin)
- Secret Manager Secret Accessor (secretmanager.secretAccessor)

> NOTE: This is not necessarily the minimal-roles, further work will refine this). Please use `scripts/create-primary-gsa.sh` to generate the GSA and key.

## Goal 4 - Setting up Inventory files

Inventory files contain information about how to connect to target machines and variables specific to the type of inventory. There are two types of files that correspond to `physical` and `cloud`. One inventory file is required for each type, so if you want to use both physical and cloud, you will have 2 inventory files.

### Cloud inventory file

Inventory for GCP is dynamic, meaning the GCP module will query the project + region for cloud resources to use as inventory. As far as Ansible is concerned, GCP inventory is dynamic so the example inventory has placeholders that are replaced using `envsubst` (NOTE: `envsubst` may need to be added to the **provisioning machine**). When running playbooks, Ansible will use the pre-provisioned GCE instances. The inventory file does NOT build new GCE machines.

1. Establish GCP Inventory File "inventory/gcp.yaml"

    ```bash
    # note "gcp.yaml", this name convention is required for the gcp module plugin
    envsubst < templates/inventory-cloud-example.yaml > inventory/gcp.yaml
    ```

> NOTE: If the `envsubst` dependency is missing, install using `apt-get install gettext-base`

### Physical Inventory file

In order to create an inventory file, use the example file `inventory-physical-example.yaml` and place the contents in `inventory/inventory.yaml`

```bash
# Example using envsubst (not required unless the example file has environment variables)
envsubst < templates/inventory-physical-example.yaml > inventory/inventory.yaml
```

> NOTE: Check the contents and make sure the quantity of hostnames is correct for your situation


## Verifying Inventory Status

1. The script `scripts/health-check.sh` was created to ensure that passwordless SSH access is functional, and Ansible inventory is properly setup. Running this script should output a one-line per machine response to a "ping" and should succeed. If there are any failures, validate and possibly repeat the steps above.

## CNUC Hostname Setup

1. If you have any `cnuc`s in use, there is a second script that provides additional helpers like cut-copy-paste ready SSH strings and `/etc/hosts` configuration. This script uses `gcloud` to query the machines and outputs their IP addresses.
    1. You can safely cut-copy-paste the SSH commands.
    1. You can also safely cut-copy-paste the lower section that correlates cnuc IPs to their hostname. This can be placed into your `/etc/hosts` file.

    > NOTE: IPs are ephemeral, so the `/etc/hosts` file may need updated over time as IPs shift

## Ready to provision

After completing all of these steps, you are ready to proceed with provisioning.


## Troubleshooting Inventory

* **IF** using WSL2 on Windows and Ubuntu, a known bug within WSL and clock synchronization exists (https://www.reddit.com/r/bashonubuntuonwindows/comments/ihq7ar/clock_for_wsl_is_different_than_windows_how_to/).  This will manifest as an error `invalid_grant` on the JWT token, despite a fresh GSA key.

    ```bash
    # Sync HW Clock (this will not work with chromebook/crostini)
    sudo hwclock -s
    ```

* Sometimes the JWT token used in the Ansible GCP plugin may expire and you will need to re-auth the `default application` credentials. Sometimes this also requires a reboot of the machine.
    * `gcloud auth application-default login`

* Try SSH to the failed connections

    ```bash
    ssh -i ~/.ssh/nuc abm-admin@<hostname>
    ## IF not successful, verify SSH key has been established and copied to target machine(s)

    ssh <hostname>
    ## If not successful, check the SSH Config for proper HOST, HOSTNAME, and USER configuration
    ```

* Very possible to hit `fingerprint` issues with SSH. Most of the time, you can run the suggested command and then SSH back into the machine and accept the new fingerprint.

    * Most of the time, you can run the suggested `ssh-keygen` command (ie: `ssh-keygen -f "/home/<user>/.ssh/known_hosts" -R "nuc-1"`) to remove the old fingerprint
