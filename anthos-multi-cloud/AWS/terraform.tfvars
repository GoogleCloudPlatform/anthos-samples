gcp_project_id          = "xxx-xxx-xxx"
admin_user              = "example@example.com"
name_prefix             = "aws-cluster"
node_pool_instance_type = "c5.2xlarge"
control_plane_instance_type = "m5.large"
cluster_version         = "1.22.8-gke.200"
#--Use 'gcloud container aws get-server-config --location [gcp-region]' to see Availability --
gcp_location              = "us-east4"
aws_region                = "us-east-1"
subnet_availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

