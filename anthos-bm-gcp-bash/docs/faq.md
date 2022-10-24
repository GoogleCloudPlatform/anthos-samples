# Frequently Asked Questions (FAQ)

The following are a list of variations with which the script can be used to
deploy Anthos on bare metal in Compute Engine VMs.

---

### Using a network other than the `default`

If you want to use a network other than the `default` network then you will have
to do the following changes:

> **Note:** The firewall rules that follow show how to replicate the same rules
> that is available by default on the `default` network. This must be used only
> to experiment with this sample.

1. Ensure that `TCP`, `UDP` and `SSH` traffic is allowed on the network of your
   choice.
   ```sh
   gcloud compute firewall-rules create abm-allow-internal \
        --project=$PROJECT_ID \
        --network=<YOUR_VPC_NETWORK> \
        --direction=INGRESS \
        --action=ALLOW \
        --rules=tcp:0-65535,udp:0-65535,icmp \
        --source-ranges=10.128.0.0/9 \
        --priority=65534
   ```
   ```sh
   gcloud compute firewall-rules create abm-allow-ssh \
        --project=$PROJECT_ID \
        --network=<YOUR_VPC_NETWORK> \
        --direction=INGRESS \
        --action=ALLOW \
        --rules=tcp:22 \
        --source-ranges=0.0.0.0/0 \
        --priority=65534
   ```

2. Update the command for creating Compute Engine VMs in the
   [install_hybrid_cluster](/anthos-bm-gcp-bash/install_admin_cluster.sh) script
   to use the network of your choice instead of `default`.

    ```sh
    ...
    ...
        --zone=${ZONE} \
        --boot-disk-size 200G \
        --boot-disk-type pd-ssd \
        --can-ip-forward \
        --network <YOUR_VPC_NETWORK> \
    ...
    ...
    ...
    ```
