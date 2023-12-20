gcp_project_id = "projectId"
#add up to 10 GCP Ids for cluster admin via connect gateway
admin_users = ["user1@domain.com", "user2@domain.com"]
name_prefix = "aws-cluster"
/* supported instance types
https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/reference/supported-instance-types
*/
node_pool_instance_type     = "t3.medium"
control_plane_instance_type = "t3.medium"
/* supported versions
https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/reference/supported-versions
*/
cluster_version             = "1.28.3-gke.700"
/*
Use 'gcloud container aws get-server-config --location [gcp-region]' to see Availability --
https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/reference/supported-regions
*/
gcp_location              = "us-east4"
aws_region                = "us-east-1"
subnet_availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
