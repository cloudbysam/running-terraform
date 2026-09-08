provider "aws" {
  region = "us-east-1"
}

module "webserver-cluster" {
  source = "../../../../modules/services/webserver-cluster"

  cluster_name           = "stage"
  server_text            = "Let's try: Hello, this is a test for zero downtime deployment."
  db_remote_state_bucket = "state-files-buc-aj"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.tfstate"

  instance_type      = "t2.micro"
  desired_capacity   = 2
  min_size           = 2
  max_size           = 4
  enable_autoscaling = false
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver-cluster.alb_security_group_id

  from_port   = 12345
  to_port     = 12345
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  security_group_id = module.webserver-cluster.ec2_security_group_id

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

output "alb_dns_name" {
  value       = module.webserver-cluster.alb-dns-name
  description = "The domain name of the load balancer"
}

import {
  to = module.webserver-cluster.aws_security_group.network
  id = "sg-0d93e40d345240598" 
}

import {
  to = module.webserver-cluster.aws_security_group.alb
  id = "sg-0e20cb37140abe757" 
}

import {
  to = module.webserver-cluster.aws_lb_target_group.asg
  id = "arn:aws:elasticloadbalancing:us-east-1:662829279164:targetgroup/stage-target-group/5d965c912ca0aac0" 
}

# Partial configuration: remaining settings (e.g., bucket, region)
# must be passed via '-backend-config' arguments during 'terraform init'. 
# terraform init -backend-config="backend.hcl"
#
# Uncomment the block below to use the S3 backend for state storage.
# terraform {
#   backend "s3" {
#     key = "stage/services/webserver-cluster/terraform.tfstate"
#   }
# }