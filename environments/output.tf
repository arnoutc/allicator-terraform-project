output "function_arn" {
  value = aws_lambda_function.event-bridge-target-lambda.qualified_arn
}