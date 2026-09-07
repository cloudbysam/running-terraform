provider "aws" {
  region = "us-east-1"
}

module "webserver-cluster" {
  source = "C:/Users/samue/AWS/Running-Terraform/modules/services/webserver-cluster"

  cluster_name           = "prod"
  db_remote_state_bucket = "state-files-buc-aj"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"

  instance_type      = "t2.micro"
  desired_capacity   = 2
  min_size           = 2
  max_size           = 4
  enable_autoscaling = true

  custom_tags = {
    Owner     = "team-sam"
    ManagedBy = "terraform"
  }
}

output "alb_dns_name" {
  value       = module.webserver-cluster.alb-dns-name
  description = "The domain name of the load balancer"
}

# Partial configuration: remaining settings (e.g., bucket, region)
# must be passed via '-backend-config' arguments during 'terraform init'.
#
# Uncomment the block below to use the S3 backend for state storage.
# terraform {
#   backend "s3" {
#     key = "prod/services/webserver-cluster/terraform.tfstate"
#   }
# }
