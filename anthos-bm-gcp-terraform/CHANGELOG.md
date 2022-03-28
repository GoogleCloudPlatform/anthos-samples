# Changelog

## [0.7.0](https://github.com/GoogleCloudPlatform/anthos-samples/compare/v0.6.2...v0.7.0) (2022-03-25)


### Features

* Enable nested virtualization support for ABM Terraform installation on GCE ([#212](https://github.com/GoogleCloudPlatform/anthos-samples/issues/212)) ([c41edb2](https://github.com/GoogleCloudPlatform/anthos-samples/commit/c41edb20837942482fe4e05307d5d1e6d405f2f7))


### Bug Fixes

* **deps:** update module github.com/gruntwork-io/terratest to v0.40.6 ([#198](https://github.com/GoogleCloudPlatform/anthos-samples/issues/198)) ([24b845d](https://github.com/GoogleCloudPlatform/anthos-samples/commit/24b845dbfbcc12de8caa3a83a8ae8b6b8d725b7d))
* **deps:** update module github.com/stretchr/testify to v1.7.1 ([#202](https://github.com/GoogleCloudPlatform/anthos-samples/issues/202)) ([91d7f2e](https://github.com/GoogleCloudPlatform/anthos-samples/commit/91d7f2ebe01caa073baec8c32fad2ee026a051f7))

### [0.6.2](https://github.com/GoogleCloudPlatform/anthos-samples/compare/v0.6.1...v0.6.2) (2022-03-03)


### Bug Fixes

* **deps:** update module github.com/gruntwork-io/terratest to v0.40.5 ([#180](https://github.com/GoogleCloudPlatform/anthos-samples/issues/180)) ([b48a622](https://github.com/GoogleCloudPlatform/anthos-samples/commit/b48a6222b4450089c222c6547836c9a31cc15b7a))
* missing services needed for setup ([#159](https://github.com/GoogleCloudPlatform/anthos-samples/issues/159)) ([7977e91](https://github.com/GoogleCloudPlatform/anthos-samples/commit/7977e9134cfcafaae16af57c521a3035e9accf81))
* zone mismatch for vm ([#190](https://github.com/GoogleCloudPlatform/anthos-samples/issues/190)) ([b85a559](https://github.com/GoogleCloudPlatform/anthos-samples/commit/b85a559da40f1419ee94639084b18e276278f78a))

### [0.6.1](https://github.com/GoogleCloudPlatform/anthos-samples/compare/v0.6.0...v0.6.1) (2022-02-25)


### Bug Fixes

* **deps:** update module github.com/gruntwork-io/terratest to v0.40.0 ([#161](https://github.com/GoogleCloudPlatform/anthos-samples/issues/161)) ([1c85f29](https://github.com/GoogleCloudPlatform/anthos-samples/commit/1c85f29e3838d1bb1fb53d31676393fb853ceb1b))
* **deps:** update module github.com/gruntwork-io/terratest to v0.40.1 ([#168](https://github.com/GoogleCloudPlatform/anthos-samples/issues/168)) ([0942cf0](https://github.com/GoogleCloudPlatform/anthos-samples/commit/0942cf05f9b2e705dc3badf585111105f4de4d2d))
* **deps:** update module github.com/gruntwork-io/terratest to v0.40.3 ([#172](https://github.com/GoogleCloudPlatform/anthos-samples/issues/172)) ([239b1d7](https://github.com/GoogleCloudPlatform/anthos-samples/commit/239b1d74250a219ac5d102eda7201c8931ad998a))

## [0.6.0](https://github.com/GoogleCloudPlatform/anthos-samples/compare/v0.5.0...v0.6.0) (2022-01-19)


### Features

* update the ABM version to 1.10.0 on the resources file ([#127](https://github.com/GoogleCloudPlatform/anthos-samples/issues/127)) ([e9e3bdb](https://github.com/GoogleCloudPlatform/anthos-samples/commit/e9e3bdbb96c5ae66f4d980cb92b240123bcc233b))

## [0.5.0](https://github.com/GoogleCloudPlatform/anthos-samples/compare/v0.4.1...v0.5.0) (2022-01-19)


### Features

* update the ABM version to 1.9.0 on the resources file ([#126](https://github.com/GoogleCloudPlatform/anthos-samples/issues/126)) ([63fa324](https://github.com/GoogleCloudPlatform/anthos-samples/commit/63fa324358195271a4dac9725e210fcc6bf54bf9))

### [0.4.1](https://www.github.com/GoogleCloudPlatform/anthos-samples/compare/v0.4.0...v0.4.1) (2021-11-15)


### Bug Fixes

* support re-running the GCE-TF scripts to create two ABM clusters in same project ([#108](https://www.github.com/GoogleCloudPlatform/anthos-samples/issues/108)) ([eb12951](https://www.github.com/GoogleCloudPlatform/anthos-samples/commit/eb12951d81fc48afcde6d9957225c2396db7df64))

## [0.4.0](https://www.github.com/GoogleCloudPlatform/anthos-samples/compare/v0.3.0...v0.4.0) (2021-08-30)


### Features

* add oslogin metadata to override project wide setting ([#71](https://www.github.com/GoogleCloudPlatform/anthos-samples/issues/71)) ([d7a29d6](https://www.github.com/GoogleCloudPlatform/anthos-samples/commit/d7a29d62c7755b66348ca774b7169eebea3367bb))


### Miscellaneous Chores

* release 0.4.0 ([1c805c6](https://www.github.com/GoogleCloudPlatform/anthos-samples/commit/1c805c626ea986f6f8c3a14a341cf7c2af864ddd))

## [0.3.0](https://www.github.com/GoogleCloudPlatform/anthos-samples/compare/v0.2.0...v0.3.0) (2021-07-26)


### process

* test and upgrade terraform version to 0.15.5 for the GCE ABM sample ([#63](https://www.github.com/GoogleCloudPlatform/anthos-samples/issues/63)) ([c7a4acc](https://www.github.com/GoogleCloudPlatform/anthos-samples/commit/c7a4acc509e4e33c5347c4aabf729fa7300e6944))


### Miscellaneous Chores

* release 0.3.0 ([0d85a84](https://www.github.com/GoogleCloudPlatform/anthos-samples/commit/0d85a84fda9c7018a695e789421ed3b8ba70210e))

## [0.2.0](https://www.github.com/GoogleCloudPlatform/anthos-samples/compare/v0.1.0...v0.2.0) (2021-07-22)


### Features

* Enable GPU support for the GCE ABM setup ([#68](https://www.github.com/GoogleCloudPlatform/anthos-samples/issues/68)) ([2d7ad48](https://www.github.com/GoogleCloudPlatform/anthos-samples/commit/2d7ad48e29cf150480ea4ec0ce3c15f1bd91f446))


### Bug Fixes

* bash trap signal error on gce-tf sample initialization script ([#66](https://www.github.com/GoogleCloudPlatform/anthos-samples/issues/66)) ([4c8a87a](https://www.github.com/GoogleCloudPlatform/anthos-samples/commit/4c8a87a9b989d7246fcb2e93097cda281ec5831b))

## 0.1.0 (2021-06-01)


### Bug Fixes

* version pin terraform-google-vm module to ~> 6.3.0 ([#31](https://www.github.com/GoogleCloudPlatform/anthos-samples/issues/31)) ([56bce27](https://www.github.com/GoogleCloudPlatform/anthos-samples/commit/56bce27f84cca4b8bb85943e1a16b60c98925bb6))
