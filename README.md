# Anthos Samples

![Continuous Integration](https://github.com/GoogleCloudPlatform/anthos-samples/workflows/Continuous%20Integration%20-%20Main/Release/badge.svg)

This repository contains code samples for [Anthos](https://cloud.google.com/anthos/docs).

---

## Contributing

#### Contributing new samples
- Please add the sample as a root level directory in the repository

- If the sample has _Golang code_ or _Terraform scripts_, then update the `tf-validate` and `go-unit-tests` jobs of [ci_any_pr.yaml](/.github/workflows/ci_any_pr.yaml) and [ci_main_branch.yaml](/.github/workflows/ci_main_branch.yaml) files to include the new sample under: `strategy.matrix`

- If the sample introduces new language _(or other files that require tests)_, then add new _job_ or _step_ to the exisiting CI workflows at `ci_any_pr.yaml` and `ci_main_branch.yaml`

#### Contributing to existing samples
- Check for the section titled **'Contributing'** in the README specfic for that sample for details.

---
### Releases
Please read the [Release Guidelines](/.github/release.md) document for details on how releases are managed for this repository.
