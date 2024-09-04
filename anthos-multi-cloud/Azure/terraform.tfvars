gcp_project_id = "projectId"
#add up to 10 GCP Ids for cluster admin via connect gateway
admin_users = ["user1@domain.com", "user2@domain.com"]
name_prefix = "azure-cluster"
/* supported instance types
https://cloud.google.com/anthos/clusters/docs/multi-cloud/azure/reference/supported-vms
*/
control_plane_instance_type = "Standard_DS2_v2"
node_pool_instance_type     = "Standard_DS2_v2"
/* supported versions
https://cloud.google.com/anthos/clusters/docs/multi-cloud/azure/reference/supported-versions
*/
cluster_version = "1.29.4-gke.200"
/*
Use 'gcloud container aws get-server-config --location [gcp-region]' to see K8s versions/ region availability --
https://cloud.google.com/anthos/clusters/docs/multi-cloud/azure/reference/supported-regions
*/
gcp_location = "us-east4"
azure_region = "eastus"
