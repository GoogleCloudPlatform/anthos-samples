/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

terraform {
  provider_meta "google" {
    # the following versions are only bumped on releases; thus the module
    # versions below might be different from what's used in the terraform
    # scripts on the master branch
    module_name           = "anthos-samples/terraform/anthos-bm-terraform:gce/v0.1.0"
    gcloud                = "terraform-google-modules/gcloud/google/v2.1.0"
    gcp_apis              = "terraform-google-modules/project-factory/google//modules/project_services/v10.3.2"
    gcp_service_accounts  = "terraform-google-modules/service-accounts/google/v~> 4.0"
    gcp_compute_instances = "terraform-google-modules/vm/google//modules/compute_instance/v~> 6.3.0"
  }
  required_version = ">= 0.15.5, < 1.1"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.68.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.68.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.credentials_file)
}

provider "google-beta" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file(var.credentials_file)
}
