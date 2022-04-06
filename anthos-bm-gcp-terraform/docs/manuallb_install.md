## Install with Manual Loadbalancer

This guide is an extension to the [all-in-one install guide](one_click_install.md). The `all-in-one install` is a single run installation which automatically triggers the complete **Anthos on bare metal** installation when the Terraform script is run. The default installation sets up Anthos on bare metal to run using a [bundled loadbalancer](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/bundled-lb). This means that the loadbalancer and the cluster services are reachable only from inside one of the GCE VMs _(i.e. Admin workstation, Controlplane nodes, Worker nodes)_ created during the installation process.

While, this setup closely represents how **Anthos on bare metal (ABM)** will be deployed in an actual enterprise baremetal environment, this is not ideal for demos. With demo environments we would like to be able to easily reach the `control plane` and the `ingress` of the Anthos on bare metal cluster without having to SSH into a jump host.

Thus, this extension _(to the terraform script)_ installs Anthos on bare metal using the [Manual LB](https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/manual-lb) mode. We use [Google Cloud Loadbalancer](https://cloud.google.com/load-balancing/docs/load-balancing-overview) as the loadbalancer fronting the Anthos on bare metal cluster.

**This new mode of installation creates **two** new Google Cloud Loadbalancers:**
1. [TCP Loadbalancer](https://cloud.google.com/load-balancing/docs/ssl): this is the loadbalancer configured to front the `API Server (Controlplane)` of the ABM cluster. You can reach the `API Server` of your cluster via the `External IP Address` associated to this loadbalancer.
   
2. [HTTP(S) Loadbalancer](https://cloud.google.com/load-balancing/docs/https): this is the loadbalancer configured to front the `Ingress Service` of the ABM cluster. You can reach the `Kubernetes Services` of your cluster via the `External IP Address` associated to this loadbalancer.
 
<p align="center">
  <img src="images/gcp_lbs.png">
  <em>
    </br>
    (click image to enlarge)
  </em>
</p>

