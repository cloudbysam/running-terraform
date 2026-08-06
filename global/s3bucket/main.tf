provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform-state" {
  bucket = "state-files-buc-aj"

  # Prevent accidental deletion of this bucket
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Enable versioning so you can see the full revision history of your state files
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform-state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block all public access to the s3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform-state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Partial configuration: remaining settings (e.g., bucket, region)
# must be passed via '-backend-config' arguments during 'terraform init'.
#
# Uncomment the block below to use the S3 backend for state storage.
# terraform {
#   backend "s3" {
#     key = "global/s3/terraform.tfstate"
#   }
# }