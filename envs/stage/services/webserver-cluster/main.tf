provider "aws" {
  region = "us-east-1"
}

module "webserver-cluster" {
  source = "C:/Users/samue/AWS/Running-Terraform/modules/services/webserver-cluster"

  cluster_name           = "stage"
  db_remote_state_bucket = "state-files-buc-aj"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"

  instance_type    = "t2.micro"
  desired_capacity = 1
  min_size         = 1
  max_size         = 2
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver-cluster.alb_security_group_id

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

output "alb_dns_name" {
  value       = module.webserver-cluster.alb-dns-name
  description = "The domain name of the load balancer"
}

# terraform {
#   backend "s3" {
#     key = "stage/services/webserver-cluster/terraform.tfstate"
#   }
# }