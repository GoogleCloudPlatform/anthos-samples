## Install an Anthos on bare metal cluster of type 'admin'

This sample shows you how to setup an **admin** Anthos clusters on bare metal
in High Availability (HA) mode using Compute Engine Virtual Machines (VMs). The
[install_admin_cluster](/anthos-bm-gcp-bash/install_admin_cluster.sh) script
encapsulates all the steps required to setup the Compute Engine VMs and to
trigger the installation of the admin cluster. The steps used for setting up the
Compute Engine VM environment in this script are the same as the ones explained
in the [Try Anthos clusters on bare metal on Compute Engine VMs](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/try/gce-vms) guide. The only differences are the number
of Compute Engine VMs used and the cluster configuration file
_(which is specific to an admin cluster)_.

### Prerequisites

- A workstation with access to the Internet _(i.e. Google Cloud APIs)_ with the following installed
  - [Git](https://git-scm.com/)
  - [Google Cloud SDK (gcloud CLI)](https://cloud.google.com/sdk/docs/install)
- A [Google Cloud Project](https://console.cloud.google.com/cloud-resource-manager?_ga=2.187862184.1029435410.1614837439-1338907320.1614299892) _(in which the resources for the setup will be provisioned)_
- The gcloud CLI must be [authenticated to Google Cloud and be configured to use
  the Google Cloud Project](https://cloud.google.com/sdk/gcloud/reference/init) you intend to use
---
### Quickstart

1. Clone this repo into the workstation from where the rest of this guide will
   be followed.

    ```sh
    git clone https://github.com/GoogleCloudPlatform/anthos-samples
    cd anthos-samples/anthos-bm-gcp-bash
    ```

2. Setup environment variables.
    ```sh
    export PROJECT_ID=<GCP_PROJECT_TO_USE>
    export ZONE=<GCP_ZONE_TO_USE>
    export ADMIN_CLUSTER_NAME=<NAME_FOR_THE_CLUSTER>
    ```

3. Run the installation script.

    ```sh
    bash install_admin_cluster.sh
    ```
    ```sh
    # expected output
    ...
    ...
    ...
    ✅ Successfully set up SSH access from admin workstation to cluster node VMs.

    🔄 Installing Anthos on bare metal...
    Pseudo-terminal will not be allocated because stdin is not a terminal.
    Enter passphrase for key '/Users/sundarpichai/.ssh/google_compute_engine': 
    Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.15.0-1021-gcp x86_64)

    * Documentation:  https://help.ubuntu.com
    * Management:     https://landscape.canonical.com
    * Support:        https://ubuntu.com/advantage

    System information as of Fri Oct 21 23:56:11 UTC 2022

    System load:  0.38               Users logged in:          0
    Usage of /:   1.4% of 193.65GB   IPv4 address for docker0: 172.17.0.1
    Memory usage: 1%                 IPv4 address for ens4:    10.142.0.2
    Swap usage:   0%                 IPv4 address for vxlan0:  10.200.0.2
    Processes:    157


    6 updates can be applied immediately.
    5 of these updates are standard security updates.
    To see these additional updates run: apt list --upgradable

    New release '22.04.1 LTS' available.
    Run 'do-release-upgrade' to upgrade to it.


    ++ gcloud config get-value project
    + export PROJECT_ID=abm-ame-cluster
    + PROJECT_ID=abm-ame-cluster
    ++ curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/cluster_id -H 'Metadata-Flavor: Google'
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
    100    20  100    20    0     0  10000      0 --:--:-- --:--:-- --:--:-- 10000
    + ADMIN_CLUSTER_NAME=abm-ame-cluster
    + export ADMIN_CLUSTER_NAME
    + bmctl create config -c abm-ame-cluster
    [2022-10-21 23:56:13+0000] Created config: bmctl-workspace/abm-ame-cluster/abm-ame-cluster.yaml
    + cat
    + bmctl create cluster -c abm-ame-cluster
    Please check the logs at bmctl-workspace/abm-ame-cluster/log/create-cluster-20221021-235613/create-cluster.log
    [2022-10-21 23:56:19+0000] Creating bootstrap cluster... OK
    [2022-10-21 23:57:35+0000] Installing dependency components... OK
    [2022-10-21 23:58:53+0000] Waiting for preflight check job to finish... OK
    [2022-10-22 00:00:23+0000] - Validation Category: machines and network
    [2022-10-22 00:00:23+0000]      - [PASSED] node-network
    [2022-10-22 00:00:23+0000]      - [PASSED] pod-cidr
    [2022-10-22 00:00:23+0000]      - [PASSED] 10.200.0.3
    [2022-10-22 00:00:23+0000]      - [PASSED] 10.200.0.3-gcp
    [2022-10-22 00:00:23+0000]      - [PASSED] gcp
    [2022-10-22 00:00:23+0000] Flushing logs... OK
    [2022-10-22 00:00:25+0000] Applying resources for new cluster
    [2022-10-22 00:00:25+0000] Waiting for cluster kubeconfig to become ready OK
    [2022-10-22 00:03:35+0000] Writing kubeconfig file
    [2022-10-22 00:03:35+0000] kubeconfig of cluster being created is present at bmctl-workspace/abm-ame-cluster/abm-ame-cluster-kubeconfig
    [2022-10-22 00:03:35+0000] Please restrict access to this file as it contains authentication credentials of your cluster.
    [2022-10-22 00:03:35+0000] Waiting for cluster to become ready OK
    [2022-10-22 00:07:35+0000] Please run
    [2022-10-22 00:07:35+0000] kubectl --kubeconfig bmctl-workspace/abm-ame-cluster/abm-ame-cluster-kubeconfig get nodes
    [2022-10-22 00:07:35+0000] to get cluster nodes status.
    [2022-10-22 00:07:35+0000] Waiting for node pools to become ready OK
    [2022-10-22 00:07:55+0000] Waiting for metrics to become ready in GCP OK
    [2022-10-22 00:08:05+0000] Moving admin cluster resources to the created admin cluster
    [2022-10-22 00:08:09+0000] Waiting for node update jobs to finish OK
    [2022-10-22 00:09:49+0000] Flushing logs... OK
    [2022-10-22 00:09:49+0000] Deleting bootstrap cluster... OK
    install_admin_cluster.sh: line 304: red: command not found
    install_admin_cluster.sh: line 305: nodeConfig:: command not found
    install_admin_cluster.sh: line 306: podDensity:: command not found
    install_admin_cluster.sh: line 307: maxPodsPerNode:: command not found
    install_admin_cluster.sh: line 308: EOB: command not found
    install_admin_cluster.sh: line 310: bmctl: command not found
    install_admin_cluster.sh: line 311: EOF: command not found
    ✅ Installation complete. Please check the logs for any errors!!!

    ✅ If you do not see any errors in the output log, then you now have the following setup:

    |---------------------------------------------------------------------------------------------------------|
    | VM Name               | L2 Network IP (VxLAN) | INFO                                                    |
    |---------------------------------------------------------------------------------------------------------|
    | abm-admin-cluster-cp1 | 10.200.0.3            | Has control plane of admin cluster running inside       |
    | abm-user-cluster-cp1  | 10.200.0.4            | 🌟 Ready for use as control plane for the user cluster  |
    | abm-user-cluster-w1   | 10.200.0.5            | 🌟 Ready for use as worker for the user cluster         |
    | abm-user-cluster-w2   | 10.200.0.6            | 🌟 Ready for use as worker for the user cluster         |
    |---------------------------------------------------------------------------------------------------------|
    ```
