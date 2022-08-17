# Overview

This project is an opinionated installation of Anthos Bare Metal designed specifically for Consumer Edge requirements.

This project is a group of Ansible playbooks and bash scripts that are used to provision and manage Anthos bare metal instances given a hardware or cloud inventory.

There are two deployment types: Hardware and Cloud. Both deployment types can co-exist. Communication between any of the ABM instances are supported over the LAN supporting the hardware or cloud instances. Networking is not configured to communicate cross network boundaries (nothing prevents this being built, just not in the scope of this project)

> **Hardware** - Scripts and Playbooks designed to deploy onto hardware servers meeting requirements.
* In this project, all hardware machines will have "nuc" as a prefix for hostname and variable names.

> **Cloud** - Scripts and Playbooks designed to be deployed into GCE Virtual Machines.
* In this project, all cloud machines will have "cnuc" as a prefix for hostname and variable names.

## TL;DR (Quick Star)

If you do not plan on contributing or changing the codebase or you do not have the ability to install the developer dependencies, the recommended approach is to use the [docker installation](docs/DOCKER_INSTALL.md).

## Terms to know

> **Target machine(s)** - The machine that the cluster is being installed into/onto (ie, NUC, GCE, etc). This is often called the "host" in public documentation.

> **Provisioning machine** - The machine that initiates the `ansible` run. This is typically a laptop or the cloud shell within the GCP console

## Provisioning

The following steps are broken into **one-time** and **repeatable steps** used to provision both ***provisioning machine*** and ***target machine(s)***. Most of the steps are common across both Hardware and Cloud deployment options, but will note when a specific step is needed for either.

Please proceed through each of the installation stages.

## Installation Stages

The installation of the Consumer Edge has a series of stages that need to be completed in sequence. Some are one-time stages, other are idempotent and therefore repeatable, but all have a test to verify the stage has been completed.

The stages are:
1. [Pre-installation Steps](#pre-installation-steps)
1. [One-time Setup](docs/ONE_TIME_SETUP.md)
1. [Install Anthos bare metal](#installing-anthos-bare-metal)

> NOTE: This solution requires `3n` machines to form a High Availability single cluster (ie: 3 instances, 6 instances, 9 instances, ...)

### Pre-Installation Steps

1. **Fork** this repository
1. This project uses Personal Access Tokens for ACM communication. [Add a token](https://docs.gitlab.com/ee/user/project/deploy_tokens/) to the Git repo with **read_repository** privilege. Remember the token name that will be used for env var **SCM_TOKEN_USER**. Copy the token string that will be uesd for env var **SCM_TOKEN_TOKEN**. Go to user **Preferences** on the top right corner.
   ![gitlab token](docs/Gitlab_token.png)

### One-Time Setup

1. Review and complete the [one-time setup](docs/ONE_TIME_SETUP.md) steps
    1. Result should be baseline provisioned inventory resources (ie, GCE instances and/or hardware machines with passwordless SSH access)

    ```bash
    # Test one-time-setup script (should see "success")
    ./scripts/verify-pre-installation.sh
    ```

## Installing Anthos Bare Metal

### Install ALL Inventory

The `site.yml` playbook is used to quickly provision ALL inventory assets (ie, `cloud` and `hardware`)

```bash
ansible-playbook -i inventory site.yml
```

## Playbooks

Below is a list of playbooks and what they are intended to be used for


|     Name      |  Description    |  Inventory  | Command/Example |  Notes/Options |
|:-------------:|:----------------|:-----------:|:----------------|:---------------|
| Everything Install | Installs and sets up all Host requirements and then installs ABM on ALL inventory | ALL | `ansible-playbook -i inventory site.yml` | Installs and updates everything from a fresh provision. `all-full-install.yml` is called from site.yml, so has the same functionality |
| Cloud Install | Install ABM from a recently provisioned machine group | CLOUD | `ansible-playbook -i inventory cloud-full-inventory.yml` | Same as "everything", but only targets `cnuc`s |
| Hardware Install | Install ABM on physical hardware (NUCs) | HARDWARE | `ansible-playbook -i inventory hardware-full-inventory.yml` | Same as "everything", but only targets `nuc`s |
| Get Remote Login Tokens | Pulls login tokens to be used in the GCP console's `Kubernetes` screen | ALL | `ansible-playbook get-login-tokens.yml -i inventory` | Use `--tags cloud` or `--tags hardware` to limit to one or the other |
| Update Ubuntu OS | Equivalent of `apt-get update && apt-get upgrade` and `gcloud components update` | ALL | `ansible-playbook -i inventory all-update-servers.yml` | Use `--tags cloud` or `--tags hardware` to limit to one or the other |
| Reset Logging | Removes all logs and frees up space on the machine | ALL | `ansible-playbook -i inventory all-hard-reset-logging.yml` | This is a lossy process and removes all logs not synced to GCP. This is intended to be used in emergency scenarios only (ie, pods being evicted due to "out of space") |
| ABM Install Software | Installs only ABM on a ready OS. Does not install tools, OS requirements or anything else | ALL | `ansible-playbook -i inventory all-install-abm-software.yml` | This is idempotent and can be used to install ABM + ACM without touching the OS. OS needs to be previously setup to meet ABM host requirements |
| ABM Remove Software | Removes only ABM. Does not change underlying OS | ALL | `ansible-playbook -i inventory all-remove-abm-software.yml` | This is idempotent and can be used to remove ABM and deregisteres cluster from GKE Hub. OS needs to be previously setup to meet ABM host requirements |


## Configuration Explanation

### Environment IPs

The below are IPs used in the installation process. The configuration for these exists in the `inventory/host_vars/<host>.yaml` files.

* control_plane_vip -- IP address that is addressable & available, not overlapping with other clusters, but not pre-allocated. This is created during the process
* ingress_vip -- Must be in the Load Balancer pool for the cluster, same rules as control_plane_vip for availability
* load_balancer_pool_cidr -- IP addresses for the LoadBalancers (bundled mode) can attach to, same rules as control_plane_vip
* control_plane_ip -- different than the `control_plane_vip`, this is the IP of the box you are installing on

> NOTE: The default inventory file sets up space for 9 LBs allocated per cluster, with 1 taken for Ingress (sufficient for POC and basic work)
