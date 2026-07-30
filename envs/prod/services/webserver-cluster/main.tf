provider "aws" {
  region = "us-east-1"
}

module "webserver-cluster" {
  source = "C:/Users/samue/AWS/Running-Terraform/modules/services/webserver-cluster"

  cluster_name           = "prod"
  db_remote_state_bucket = "state-files-buc-aj"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  desired_capacity = 2
  min_size = 2
  max_size = 4
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name  = "scale_out_during_business_hours"
  min_size               = 2
  max_size               = 4
  desired_capacity       = 4
  recurrence             = "0 9 * * *"
  autoscaling_group_name = module.webserver-cluster.asg_name
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  scheduled_action_name  = "scale_in_at_night"
  min_size               = 2
  max_size               = 2
  desired_capacity       = 2
  recurrence             = "0 17 * * *"
  autoscaling_group_name = module.webserver-cluster.asg_name
}

output "alb_dns_name" {
  value       = module.webserver-cluster.alb-dns-name
  description = "The domain name of the load balancer"
}

# terraform {
#   backend "s3" {
#     key = "prod/services/webserver-cluster/terraform.tfstate"
#   }
# }
