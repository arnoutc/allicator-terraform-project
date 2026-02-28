provider "aws" {
  region  = var.aws_region
  profile = "default"

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/administrator"
  }
}