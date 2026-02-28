variable "aws_account_id" {
  type = string
}
variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(any)
}

variable "private_subnets" {
  type = list(any)
}

variable "public_subnets" {
  type = list(any)
}

# Variable to provide the secret from TF var/CI (never commit plain text)
variable "webhook_secret_value" {
  description = "Initial webhook shared secret"
  type = string
  sensitive = true
}