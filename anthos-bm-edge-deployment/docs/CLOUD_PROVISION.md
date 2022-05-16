# Overview

This document describes how to create and provision Google Cloud compute machines to emulate a physical machine similar to a NUC. Each group of 3 machines will create a VXLAN bridge between each other based on a unique VXLAN_ID.

Each GCE is created with a metadata init-script that provisions itself to be the same setup as the NUC/Hardware option.

## Create CNUC instances

This step is intended to describe how to create a CNUC machine that is a replica of a physical NUC.

1. Run the `scripts/cloud/create-cloud-gce-baseline.sh` with the following command-line switches:

    * -c {number of machines in multiples of 3}
    * -z {GCP Zone} (optional)
    * -t {create Preemptive machines} (optional)

    > NOTE: The count of machines needs to be a multiple of 3. Any other configuration will/should fail

    > NOTE: Each set of 3 machines represents a single cluster. Each cluster will have their own VXLAN ID to isolate communcation to it's own cluster.

    > NOTE: If a GCE instance already exists, the script will skip that GCE. So to build more machines, increase the `-c {count}` larger than the current set. For example, if there are 3 cnucs, using `-c 6` would create 3 more in addition to the existing 3 cnucs.

    ```bash
    # Create 3 CNUCs (provisions cnuc-1, cnuc-2 and cnuc-3)
    ./scripts/cloud/create-cloud-gce-baseline.sh -c 3
    ```

## Create More Clusters

1. Creating a second 3-machine cluster requires a different ZONE due to quota violations.
    ```bash
    # Create 3 CNUCs (provisions cnuc-4, cnuc-5 and cnuc-6)
    ./scripts/cloud/create-cloud-gce-baseline.sh -c 6 -z us-central1-a
    ```

### Verify Provisioning

1. Verify the creation and IP addresses of the `cnucs`.

    > NOTE: The initial provisioning of each CNUC may take up to 5 minutes.

    ```bash
    ./scripts/status.sh
    ```
1. The above script will output text that can be used to cut-copy-paste and use as `ssh` commands. Additionally, the second section can be placed in the `/etc/hosts` file for hostname lookups on CNUC machines. Keep in mind that the IPs are ephemeral, so the `/etc/hosts` file may need to be updated from time-to-time (along with ssh fingerprints in `known_hosts`)

## Removing CNUCs

There is currently no surgerical removal of CNUC clusters, there is a script that is a remove-all option. The script un-registers the CNUCs from the `gke hub` and removes the GCE machines.

```bash
./scripts/cloud/delete-cloud-gce-baseline.sh`
```

> NOTE: If you manually remove CNUC(s) you will need to deregister clusters from the GKE Hub (GKE screen in Console)
