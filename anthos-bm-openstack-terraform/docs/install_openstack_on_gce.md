### Deploying OpenStack Ussuri on Google Compute Engine VMs

This guide explains how to install an OpenStack _(Ussuri)_ environment on Google
Compute Engine (GCE) VMs using [nested virtualization](https://cloud.google.com/compute/docs/instances/nested-virtualization/overview).

The guide is split into 3 sections:
- Create a GCE instance with KVM enabled in Google Cloud Platform
- Install **OpenStack Ussuri** using the **[openstack-ansible in all-in-one](https://docs.openstack.org/openstack-ansible/latest/user/aio/quickstart.html)** mode
- Access and validate the deployed environment

Nested virtualization refers to the ability of running a virtual machine within
another, enabling this general concept extendable to an arbitrary depth.
Using nested KVM allows us to have minimal performance degradation when
OpenStack spins up user VMs in the GCE VM.

> **Note:** This is only for experimental purposes for trying OpenStack, **not**
> for running any actual workloads
---

#### Create a GCE instance with KVM enabled in Google Cloud Platform

In this section we will create an Ubuntu 18.04 image that has a special license attached. Note that this is required. At this point in time you can not enable nested KVM without that license being attached. So you have to create a new VM and can’t use nested KVM on any existing VM.
