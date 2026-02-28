module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "Allicator UK ${terraform.workspace}"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}