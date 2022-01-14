resource "google_gke_hub_feature" "acm" {
  provider = google-beta
  name     = "configmanagement"
  location = "global"
}

resource "google_gke_hub_feature_membership" "feature_member" {
  provider   = google-beta
  location   = "global"
  feature    = google_gke_hub_feature.acm.name
  membership = var.membership
  configmanagement {
    version = "1.9.1"
    config_sync {
      source_format = "unstructured"
      git {
        sync_repo      = "https://github.com/terraform-google-modules/terraform-google-kubernetes-engine.git"
        sync_branch    = "master"
        policy_dir     = "/examples/acm-terraform-blog-part2/config-root"
        secret_type    = "none"
        sync_wait_secs = "60"
      }
    }
    policy_controller {
      enabled                    = true
      referential_rules_enabled  = true
      template_library_installed = true
    }

  }
}