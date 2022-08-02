# Customize Cloud Logging logs with Fluent Bit for Anthos Multi-Cloud

This repository contains files that can be used to deploy a Fluent Bit
DaemonSet on an Anthos Multi-Cloud cluster. The Fluent Bit DaemonSet
customizes Cloud Logging logs for Anthos clusters on AWS and Anthos clusters
on Azure. The repository also contains files used to build a `test-logger`
sample application.

The files are adapted from the
[Google Kubernetes Engine version](https://github.com/GoogleCloudPlatform/community/tree/master/tutorials/kubernetes-engine-customize-fluentbit) of this
repository and [corresponding GKE tutorial](https://cloud.google.com/community/tutorials/kubernetes-engine-customize-fluentbit).