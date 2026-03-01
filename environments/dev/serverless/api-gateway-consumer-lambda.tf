data "archive_file" "api-gateway-consumer-lambda.zip" {
  type = "zip"
  source_file = "${path.module}/api-gateway-consumer-lambda.py"
  output_path = "${path.module}/api-gateway-consumer-lambda.zip"
}

resource "aws_lambda_function" "api-gateway-consumer-lambda" {
  function_name = "webhook-handler"
  role = aws_iam_role.lambda_exec.arn
  handler = "index_handler"
  runtime = "python3.14"
  filename = data.archive_file.api-gateway-consumer-lambda.zip.output_path
  architectures = ["arm64"]

  environment {
    variables = {
      WEBHOOK_SECRET = "replace-with-secret-or-use-secrets-manager",
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.name
    }
  }
}
