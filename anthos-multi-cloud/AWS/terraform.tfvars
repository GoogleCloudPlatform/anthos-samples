gcp_project_id          = "xxx-xxx-xxx"
admin_user              = "example@example.com"
name_prefix             = "aws-cluster"
node_pool_instance_type = "t3.medium"
cluster_version         = "1.21.5-gke.2800"
#--Use 'gcloud container aws get-server-config --location [gcp-region]' to see Availability --
gcp_location              = "us-east4"
aws_region                = "us-east-1"
subnet_availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

