## NFS Shared Storage

An optional NFS server can be provisioned to provide shared storage to the **Anthos on bare metal** cluster.  In the standard [Quick Starter](quickstart.md) method, commands are provided to install the NFS Container Storage Interface (CSI) driver, in the [All in one install](one_click_install.md) or [Manual LB install](manuallb_install.md) methods this is done automatically.

---
### Sections
  - [Prerequisites](#prerequisites)
  - [NFS setup in default install mode](#default-install)
  - [NFS setup in All-In-One / ManualLB mode](#all-in-one-or-manual-lb-install)
  - [Cleanup](#cleanup)
---
### Prerequisites
- This guide has the [same pre-requisites as the quickstart guide](/anthos-bm-gcp-terraform/README.md#pre-requisites).

### Default install

1. Follow the standard [Quick starter](quickstart.md) except additionally add the following variable to your `terraform.tfvars` file.
```sh
# terraform.tfvars file
...
nfs_server = true
...
```

2. Once the terraform installation completes, you should see extra steps _(in addition to the common ones from the Quick starter)_, showing you how to install the `NFS Driver` into your cluster.
SSH into your **admin workstation** and ensure that the `KUBECONFIG` environment variable is set to the path of your Anthos on bare metal cluster context file.
```sh
# download the NFS CSI driver installation script and run it
# the script configures your cluster to support the NFS storage
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/v3.1.0/deploy/install-driver.sh | bash -s v3.1.0 --
# create a new StorageClass for NFS storage
kubectl apply -f $HOME/nfs-csi.yaml
```

3. Verify the available storage classes
```sh
kubectl get storageclass

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

### All in one or Manual LB install

1. Follow the [All in one install](one_click_install.md) or [Manual LB install](manuallb_install.md) guides except additionally add the following variable to your `terraform.tfvars` file.
```sh
# terraform.tfvars file
...
nfs_server = true
...
```

With `nfs_server` set to `true`, the *All in one* and *Manual LB install* modes automatically configure everything required for the `NFS CSI`.

2. Once the cluster is fully deployed, verify the available storage classes
```sh
kubectl get storageclass

# expected output should include
NAME            PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
nfs-csi         nfs.csi.k8s.io                 Delete          Immediate              false                  5m
```

3. The `nfs-csi` storage class can now be utilized for your `PersistantVolumeClaims`.
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
