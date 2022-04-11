## What is this?

ABM nettest enables users/support members to find any connectivity issues
among k8s pods/nodes/svcs/external targets (except for connections from external
targets to pods/nodes/svcs). This playbook will help to quickly spot any
connectivity issues among k8s components in the cluster of interest.

## Quickstart

### Run Nettest

Run the nettest by running the following commands.

For non-RHEL OS:

```
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/anthos-samples/main/anthos-bm-utils/abm-nettest/nettest.yaml
```

For RHEL OS:

```
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/anthos-samples/main/anthos-bm-utils/abm-nettest/nettest_rhel.yaml
```

NOTE: private registry users needs to download the manifest and modify all image names respectively.

### Cleanup

After tests are finished, we can cleanup the artifacts via running:

```
kubectl delete namespace nettest
kubectl delete clusterroles nettest:nettest
kubectl delete clusterrolebindings nettest:nettest
```

## Appendix

### How to interpret nettest logs {#howto-interpret-logs}

In the nettest pod logs, you will see the following lines:

```
"Error rate in percentage": probe from {src} to {dst} has value 100.000000, threshold is 1.000000
```

Here, `{src}` and `{dst}` can be either:

*   The echoserver pod IP (meaning the connection to/from a pod on the node), or
*   The node IP (meaning the connection to/from the node), or
*   Service IP (see below)

In addition, `{dst}` can also be:

*   google.com (meaning the connection to external)
*   dns (meaning the connection to non-hostnetwork service via dns)

The details for service IP can be found in the probe sections above. For
example, the following probe is saying that 172.26.27.229:80 is
`service-clusterip` (and you will see two probes that has same targets - one for
pod and another for vm)

```
probe {
  name: "vm-service-clusterip"
  …
  targets {
    host_names: "172.26.27.229:80"
  }
```
