resource "aws_cloudwatch_event_bus" "bus" {
  name = var.event_bus_name
}

# IAM policy allowing the ingress Lambda to PutEvents to the bus
resource "aws_iam_policy" "put_events_policy" {
  name        = "lambda-put-events-${var.event_bus_name}"
  description = "Allow Lambda to publish events to EventBridge bus"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:PutEvents"
        ]
        Resource = aws_cloudwatch_event_bus.bus.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_put_events" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.put_events_policy.arn
}

# Eventbridge Rule: route based on source + allowed detail-type
resource "aws_cloudwatch_event_rule" "webhook_events" {
  name           = "webhook-events-rule"
  description    = "Route webhook events from ingress to consumer Lambda"
  event_bus_name = aws_cloudwatch_event_bus.bus.name

  event_pattern = jsonencode({
    "source" : [var.event_source]          # e.g., "webhook.ingress"
    "detail-type" : var.event_detail_types # e.g., ["webhook.event", "order.created"]
    # You can also match on fields inside "detail" (the original payload)
    # "detail": { "accountId": ["12345"] }
  })
}

# Event target = consumer Lambda with DLQ + retry policy
resource "aws_cloudwatch_event_target" "to_consumer" {
  rule           = aws_cloudwatch_event_rule.webhook_events.name
  event_bus_name = aws_cloudwatch_event_bus.bus.name
  target_id      = "lambda-consumer"
  arn            = aws_lambda_function.consumer.arn

  # Pass-thru entire Detail as-is (default). Optionally, use input_transformer to reshape.
  # input_transformer { ... }
  dead_letter_config {
    arn = aws_sqs_queue.target_dlq.arn
  }

  retry_policy {
    maximum_event_age_in_seconds = 3600 # 1 hour; can be up to 24h (86400)
    maximum_retry_attempts       = 24   # up to 185 per docs; choose what fits
  }
}

# Allow EventBridge to invoke the consumer Lambda
resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.consumer.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.webhook_events.arn
}

resource "aws_cloudwatch_event_archive" "webhook_archive" {
  name             = "webhook-events-archive"
  description      = "Archive of webhook events for replay"
  event_source_arn = aws_cloudwatch_event_bus.bus.arn
  retention_days   = 7

}

# Optional Input transformer
# resource "aws_cloudwatch_event_target" "to_consumer_transformed" {
#   rule           = aws_cloudwatch_event_rule.webhook_events.name
#   event_bus_name = aws_cloudwatch_event_bus.bus.name
#   target_id      = "lambda-consumer-transformed"
#   arn            = aws_lambda_function.consumer.arn

#   input_transformer {
#     input_paths = {
#       id    = "$.detail.id"
#       dtype = "$.detail-type"
#       src   = "$.source"
#       body  = "$.detail"
#     }

#     input_template = <<EOF
# {
#   "meta": {
#     "source": <src>,
#     "type": <dtype>,
#     "id": <id>
#   },
#   "payload": <body>
# }
# EOF
#   }

#   dead_letter_config {
#     arn = aws_sqs_queue.target_dlq.arn
#   }

#   retry_policy {
#     maximum_retry_attempts       = 24
#     maximum_event_age_in_seconds = 3600
#   }
# }