# Releasing Guidelines

Releases for this repo are managed by [release-please](https://github.com/googleapis/release-please). Configurations for *release-please* can be found in the [release-please.yml](.github/release-please.yml) file.

> **Note:** You may notice that the configuration is specific to the
> [anthos-bm-gcp-terraform](/anthos-bm-gcp-terraform) sample. This is because
> that is the only sample we continuously run tests on, update Anthos versions
> and validate against new versions of _Terraform_.

Releases are automatically triggered by the release-please bot based on commit
messages and pull-request titles. Read the information on the
[release-please github repository](https://github.com/googleapis/release-please#how-should-i-write-my-commits) for details on how the type of
release is decided by the bot. A release for this repository basically means
that we **tag** the latest state of the **main** branch with the release
version.

Whenever it is time for a release, release-please will trigger a release
pull-request. See this [**example pull-request**](https://github.com/GoogleCloudPlatform/anthos-samples/pull/302). Few things to check before merging
a release pull-request:

- Make sure that all the CI tests pass.

- Release please will automatically update the Terraform version in the
  [versions.tf](/anthos-bm-gcp-terraform/versions.tf) with the release version.
  This is an issue with the Terraform releaser plugin of the release-please bot.
  So we should edit the pull-request _(we can do this directly in Github)_ to
  revert this change. _([See example revert](https://github.com/GoogleCloudPlatform/anthos-samples/pull/302/commits/e4329bcdc074501957904e357e3b889b7d9056f9))_
- Check if a latest version of the **NFS CSI Driver** is available. You can find
  the releases versions [here](https://github.com/kubernetes-csi/csi-driver-nfs/releases/tag/v4.0.0).
  If available update the references for the **NFS CSI** driver to the latest
  version.
    - [outputs.tf](/anthos-bm-gcp-terraform/outputs.tf#L47)
    - [install_abm.sh](/anthos-bm-gcp-terraform/resources/install_abm.sh#L49)
    - [nfs.md](/anthos-bm-gcp-terraform/docs/nfs.md) _(Line 30)_

Once you have verified the above, you can go ahead and merge the release
pull-request 🚀

---
### Updating the cloud-foundation-toolkit image version

We use the [GoogleCloudPlatform/cloud-foundation-toolkit (CFT)](https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit) for out integration tests. Thus, the versions of tools
used during our integration tests are reliant on the versions installed inside
the docker image of the cloud-foundation-toolkit
[we reference in our test suite](/Makefile#L23).

Thus, we update tools we rely on _(e.g. Terraform)_ based on the latest
supported versions in the _GoogleCloudPlatform/cloud-foundation-toolkit_. We can
check what are the versions supported by the CFT by looking at the
[infra/build/Makefile](https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/blob/v0.4.4/infra/build/Makefile) in the CFT repository
**under the release version tag of interest**.

For example **v0.4.4** of the CFT [uses Terraform version 1.1.7](https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/blob/v0.4.4/infra/build/Makefile#L16).
If we want our samples to use this version of the CFT then we have to update
references to the CFT docker image in our repository to point to the version
set for [DOCKER_TAG_VERSION_DEVELOPER_TOOLS](https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/blob/v0.4.4/infra/build/Makefile#L35); which is
**1.4.13** in this example. The places where you will have to update this
version are:
- [Makefile](/Makefile#L23)
- [int.cloudbuild.yaml](/build/int.cloudbuild.yaml#L67)
- [lint.cloudbuild.yaml](/build/lint.cloudbuild.yaml#L27)
