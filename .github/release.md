# Releasing Guidelines

Releases for this repo are managed by [release-please](https://github.com/googleapis/release-please). Configurations for *release-please* can be found in the [release-please.yml](.github/release-please.yml) file.

> **Note:** You may notice that the configuration is specific to the
> [anthos-bm-gcp-terraform](/anthos-bm-gcp-terraform) sample. This is because
> that is the only sample we continuosuly run tests on, update Anthos versions
> and validate against new versions of _Terraform_.

Releases are automatically triggered by the release-please bot based on commit
messages and pull-request titles. Read the information on the
[release-please github repository](https://github.com/googleapis/release-please#how-should-i-write-my-commits) for information on how it is
decided what type of release to be triggered. A release for this repository
basically means that we **tag** the latest state of the **main** branch with the
release version.

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