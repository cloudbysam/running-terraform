provider "aws" {
  region = "us-east-1"
}

module "mysql_database" {
  source = "../../../../modules/data-stores/mysql"
  db_name = "aws_database_stage"
  instance_class    = "db.t3.micro"
  allocated_storage = 10

  db_username = var.db_username
  db_password = var.db_password
}

# Partial configuration: remaining settings (e.g., bucket, region)
# must be passed via '-backend-config' arguments during 'terraform init'.
#
# Uncomment the block below to use the S3 backend for state storage.
terraform {
  backend "s3" {
    key = "stage/data-stores/mysql/terraform.tfstate"
  }
}