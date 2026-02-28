output "address" {
  value = aws_rds_cluster.cluster.endpoint
  description = "Connect to the database at this endpoint"
}

output "port" {
  value = aws_rds_cluster.cluster.port
  description = "The port the database is listening on"
}