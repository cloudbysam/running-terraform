provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "database" {
  identifier_prefix   = "database-instance"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t3.micro"
  skip_final_snapshot = true
  db_name             = "aws_database"

  username = var.db_username
  password = var.db_password
}

# Partial configuration: remaining settings (e.g., bucket, region)
# must be passed via '-backend-config' arguments during 'terraform init'.
#
# Uncomment the block below to use the S3 backend for state storage.
# terraform {
#   backend "s3" {
#     key = "stage/data-stores/mysql/terraform.tfstate"
#   }
# }