gcp_project_id          = "project-id"
admin_user              = "example@example.com"
name_prefix             = "aws-cluster"
node_pool_instance_type = "t3.medium"
control_plane_instance_type = "t3.medium"
/* check the following for image size guidelines
 https://cloud.google.com/anthos/clusters/docs/multi-cloud/aws/reference/supported-instance-types
*/
cluster_version         = "1.22.8-gke.200"
#--Use 'gcloud container aws get-server-config --location [gcp-region]' to see Availability --
gcp_location              = "us-east4"
aws_region                = "us-east-1"
subnet_availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

