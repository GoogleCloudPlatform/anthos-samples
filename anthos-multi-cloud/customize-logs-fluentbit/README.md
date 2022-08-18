# Customize Cloud Logging logs with Fluent Bit for Anthos Multi-Cloud

This repository contains files to deploy a Fluent Bit
DaemonSet on an Anthos Multi-Cloud cluster. Fluent Bit can be used to
customize Cloud Logging logs for Anthos clusters on AWS and Anthos clusters
on Azure. The repository also contains files that build a `test-logger`
sample application.

The files are adapted from the
[Google Kubernetes Engine version](https://github.com/GoogleCloudPlatform/community/tree/master/tutorials/kubernetes-engine-customize-fluentbit) of this
repository and [corresponding GKE tutorial](https://cloud.google.com/community/tutorials/kubernetes-engine-customize-fluentbit).
