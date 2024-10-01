/**
 * Copyright 2022-2024 Google LLC
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
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.14"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.94"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.5.0, < 7"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4"
    }
  }
  required_version = ">= 0.13"
}

provider "azurerm" {
  features {}
}

provider "azuread" {
  /**
   * update this block with your default Azure Active Directory information
   * like tenant_id or client_id.
   */
}

provider "google" {
  project = var.gcp_project_id
}
