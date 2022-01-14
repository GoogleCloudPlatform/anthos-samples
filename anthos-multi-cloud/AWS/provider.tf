terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.5.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}
provider "google" {
  project = var.gcp_project_id
}
