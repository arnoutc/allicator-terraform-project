# variable "db_subnet_ids" {
#     description = "Private subnet IDs across at least 2 AZs for the DB subnet group"
#     type        = list(string)
# }

variable "vpc_security_group_ids" {
    description = "Security group IDs to attach to the Aurora cluster"
    type        = list(string)
    default     = ["sg-0d7ab9d7d004b20f0"]
}


variable "master_user_name" {
  description   = "The username for the master database root user"
  type          = string
}

variable "master_password" {
  description   = "The password for the master database user"
  type          = string
  sensitive     = true
}

variable "cluster_identifier" {
  description   = "Aurora cluster identifier"
  type          = string
  default       = "aurora-pg-alv2-demo"
}

variable "database_name" {
  description   = "Initial database name"
  type          = string
  default       = "appdb"
}

variable "engine_version" {
  description   = "Aurora PostgreSQL engine version. Leave null to use the AWS default"
  type          = string
  default       = null
}