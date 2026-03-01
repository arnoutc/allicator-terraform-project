resource "aws_sqs_queue" "target_dlq" {
  name = var.dlq_name
}

# Optional: IAM policy for EventBridge to send to SQS DLQ is implicit via AWS service principal,
# but some orgs prefer explicit resource policies on SQS. Typical implicit permissions suffice.
