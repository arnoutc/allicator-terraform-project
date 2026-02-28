output "function_arn" {
  value = aws_lambda_function.event-bridge-target-lambda.qualified_arn
}

output "invoke_url" {
  value = aws_apigatewayv2_api.http.api_endpoint
}