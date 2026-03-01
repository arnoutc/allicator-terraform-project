output "invoke_url" {
  value = aws_apigatewayv2_api.http.api_endpoint
}

output "event_bus_name" {
  value = aws_cloudwatch_event_bus.bus.name
}

output "event_rule_arn" {
  value = aws_cloudwatch_event_rule.webhook_events.arn
}

output "target_dlq_url" {
  value = aws_sqs_queue.target_dlq.id
}
