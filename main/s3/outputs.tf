output "s3_bucket_arn" {
  value                    = aws_s3_bucket.allicator-tf-state.arn
  description              = "The ARN of the S3 state bucket"
}

output "dynamodb-state-table-name" {
    value                  = aws_dynamodb_table.allicator-tf-locks.name
    description            = "The name of the DynamoDB state table"
}