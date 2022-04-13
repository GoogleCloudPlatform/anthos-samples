## What is this?

ABM nettest enables users/support members to find any connectivity issues
among k8s pods/nodes/svcs/external targets (except for connections from external
targets to pods/nodes/svcs). This playbook will help to quickly spot any
connectivity issues among k8s components in the cluster of interest.

## Quickstart

### Run nettest

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

### Get the test result

Run the following command to see the nettest result:

```
kubectl -n nettest logs nettest -c nettest
```

While the nettest is running, you will see messages like the following:

```
I0413 03:33:04.879141       1 collectorui.go:130] Listening on ":8999"
I0413 03:33:04.879258       1 prometheus.go:172] Running prometheus controller
E0413 03:33:04.879628       1 prometheus.go:178] Prometheus controller: failed to retries probers: Get "http://127.0.0.1:9090/api/v1/targets": dial tcp 127.0.0.1:9090: connect: connection refused
```

NOTE: the `connection refused` message is expected. You will see the result in 5 minutes.

If the nettest ran successfully (didn't find any connection issues), you will see the following log:

```
I0211 21:58:34.689290       1 validate_metrics.go:78] Metric validation passed!
```

If the nettest failed (found some connection issues), you will see the following logs:

```
E0211 06:40:11.948634       1 collector.go:65] Engine error: step validateMetrics failed:
"Error rate in percentage": probe from "10.200.0.3" to "172.26.115.210:80" has value 100.000000, threshold is 1.000000
"Error rate in percentage": probe from "10.200.0.3" to "172.26.27.229:80" has value 100.000000, threshold is 1.000000
"Error rate in percentage": probe from "192.168.3.248" to "echoserver-hostnetwork_10.200.0.2_8080" has value 2.007046, threshold is 1.000000
```


### Cleanup

After tests are finished, we can cleanup the artifacts via running:

```
kubectl delete namespace nettest
kubectl delete clusterroles nettest:nettest
kubectl delete clusterrolebindings nettest:nettest
```

## Appendix

### How to interpret nettest logs

When nettest fails, you will see the following lines in the nettest pod logs:

```
"Error rate in percentage": probe from {src} to {dst} has value 100.000000, threshold is 1.000000
```

Here, `{src}` and `{dst}` can be either:

*   The echoserver pod IP (meaning the connection to/from a pod on the node), or
*   The node IP (meaning the connection to/from the node), or
*   Service IP (see below)

In addition, `{dst}` can also be:

*   google.com (meaning the connection to external)
*   dns (meaning the connection to non-hostnetwork service via dns, i.e. `echoserver-non-hostnetwork.nettest.svc.cluster.local`)

The details for service IP can be found in the probe sections above. For
example, the following probe is saying that 172.26.27.229:80 is
`service-clusterip` (and you will see two probes with this `targets` - one for
pod, `pod-service-clusterip` and another for vm, `vm-service-clusterip`)

```
probe {
  name: "vm-service-clusterip"
  …
  targets {
    host_names: "172.26.27.229:80"
  }
```
