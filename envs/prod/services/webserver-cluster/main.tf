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

  # Turn on Route 53 for Production 
  enable_route53 = true
  domain_name    = "awswithsam.site " 


  custom_tags = {
    Owner     = "team-sam"
    ManagedBy = "terraform"
  }
}


# Partial configuration: remaining settings (e.g., bucket, region)
# must be passed via '-backend-config' arguments during 'terraform init'.
#
# Uncomment the block below to use the S3 backend for state storage.
terraform {
  backend "s3" {
    key = "prod/services/webserver-cluster/terraform.tfstate"
  }
}
