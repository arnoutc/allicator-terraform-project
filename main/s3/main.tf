provider "aws" {
  region                    = "eu-west-2"
}

# Steps to implement the remote state 
# First manually create s3 bucket allicator-tf-state
# run a terraform import aws_s3_bucket.allicator-tf-state allicator-tf-state

resource "aws_s3_bucket" "allicator-tf-state" {
  bucket                    = "allicator-tf-state"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy         = true
  }
}

# Enable versioning so that you can see the full revision history 
# of your state files
resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.allicator-tf-state.id
    versioning_configuration {
      status                = "Enabled"
    }
}

# Enable server-side encryption by default 
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
    bucket = aws_s3_bucket.allicator-tf-state.id

    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm       = "AES256"
      }
    }
}

# Explicitly block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket                  = aws_s3_bucket.allicator-tf-state.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_dynamodb_table" "allicator-tf-locks" {
    name                    = "allicator-tf-locks"
    billing_mode            = "PAY_PER_REQUEST"
    hash_key                = "LockID"

    attribute {
      name                  = "LockID"
      type                  = "S"
    }
}

terraform {
  backend "s3" {
    bucket                  = "allicator-tf-state"
    key                     = "global/s3/terraform.tfstate"
    region                  = "eu-west-2"
    use_lockfile            = true
    encrypt                 = true
  }
}
