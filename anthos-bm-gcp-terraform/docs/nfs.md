## NFS Shared Storage

An optional NFS server can be provisioned to provide shared storage to the **Anthos on bare metal** cluster. If you follow the standard [Quick Starter](quickstart.md) guide, then the commands required to install the [**NFS Container Storage Interface (CSI)** driver](https://kubernetes.io/docs/concepts/storage/volumes/#nfs) are provided as part of the Terraform output. If you followed one of [All in one install](one_click_install.md) or [Manual LB install](manuallb_install.md) guides then everything is setup automatically.

---
### Sections
  - [Prerequisites](#prerequisites)
  - [Steps](#steps)
  - [Cleanup](#cleanup)
---
### Prerequisites
- This guide has the [same pre-requisites as the quickstart guide](/anthos-bm-gcp-terraform/README.md#pre-requisites).
---

### Steps

1. Follow any of the guides *([Quick starter](quickstart.md), [All in one install](one_click_install.md) or [Manual LB install](manuallb_install.md))* with one additional variable added to the `terraform.tfvars` file.

    ```sh
    # terraform.tfvars file
    ...
    nfs_server = true
    ...
    ```
2. The [All in one install](one_click_install.md) and [Manual LB install](manuallb_install.md) guides will automatically setup everything required for the NFS storage class to be available.

    However, for the **[Quick starter](quickstart.md)** mode installation, you will see some additional steps _(in addition to the common ones from the     Quick starter)_, printed out as part of the *Terraform output*. Run those commands from inside your admin-workstation to install the `NFS Driver`       into your cluster.

    SSH into your **admin workstation** and ensure that the `KUBECONFIG` environment variable is set to the path of your Anthos on bare metal cluster       context file.
    ```sh
    # example output for the Quick starter installation with 'nfs_server = true'

    ################################################################################
    #     Configure the cluster to utilize NFS for PVs with the NFS-CSI driver     #
    ################################################################################
    > export KUBECONFIG=bmctl-workspace/cluster1/cluster1-kubeconfig && \
      curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/v3.1.0/deploy/install-driver.sh | bash -s v3.1.0 -- && \
      kubectl apply -f nfs-csi.yaml

    ################################################################################
    ```

3. Verify the availability of the NFS storage classes
    ```sh
    kubectl get storageclass
    ```
    ```sh
    # expected output should include
    NAME            PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
    nfs-csi         nfs.csi.k8s.io                 Delete          Immediate              false                  5m
    ```

4. The `nfs-csi` storage class can now be utilized for your `PersistantVolumeClaims`.
    ```sh
    # example for a DataVolume
    ...
    spec:
      pvc:
        storageClassName: nfs-csi
    ...
    ```
---
### Cleanup

- Follow the [same cleanup steps as the quickstart guide](quickstart.md#cleanup).
