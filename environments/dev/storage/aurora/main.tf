terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.33"
    }
  }

  backend "s3" {
    bucket                  = "allicator-tf-state"
    key                     = "dev/storage/aurora/terraform.tfstate"
    region                  = "eu-west-2"
    encrypt                 = true
    dynamodb_table          = "allicator-tf-locks"
  }
}


provider "aws" {
  region = "eu-west-2"
}

data "aws_vpc" "default" {
  default                 = true
}

data "aws_subnets" "default" {
  filter {
    name                  = "vpc-id"
    values                = [data.aws_vpc.default.id]
  }
}


################################################################################
# Networking prerequisites
################################################################################


resource "aws_db_subnet_group" "this" {
  name       = "${var.cluster_identifier}-subnets"
  subnet_ids = data.aws_subnets.default.ids
  description = "DB subnet group for ${var.cluster_identifier}"

  tags = {
    Name        = "${var.cluster_identifier}-subnets"
    Environment = "dev"
  }
}

################################################################################
# Aurora PostgreSQL Serverless v2 Cluster
################################################################################

resource "aws_rds_cluster" "this" {
    cluster_identifier = var.cluster_identifier
    engine = "aurora-postgresql"
    engine_mode = "provisioned"
    engine_version = "16.4"
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier = var.cluster_identifier

  engine = "aurora-postgresql"
  engine_mode = "provisioned"
  engine_version = aws_rds_cluster.this.engine_version

  database_name = var.database_name
  master_username = var.master_user_name
  master_password = var.master_password

  storage_encrypted = true
  skip_final_snapshot = true
  apply_immediately = true

  enable_http_endpoint = true

  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.vpc_security_group_ids

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 5
  }

  tags = {
    Name = var.cluster_identifier
    Engine = "aurora-postgresql"
    Environment = "dev"
  }

  timeouts {
    delete = "30m"
  }
}


################################################################################
# Serverless v2 Instances
################################################################################

# Two instances for HA; adjust count as needed
resource "aws_rds_cluster_instance" "instances" {
  count = 2

  identifier = "${var.cluster_identifier}-${count.index + 1}"
  cluster_identifier = aws_rds_cluster.cluster.id

  engine = aws_rds_cluster.cluster.engine
  engine_version = aws_rds_cluster.cluster.engine_version

  instance_class = "db.serverless"

  publicly_accessible = false
  apply_immediately = true


  # Enhanced monitoring example (optional):
  # monitoring_interval = 60
  # monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  timeouts {
    delete = "30m"
  }

  tags = {
    Name        = "${var.cluster_identifier}-${count.index + 1}"
    Environment = "dev"
  }

}