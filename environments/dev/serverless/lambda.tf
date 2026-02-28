data "archive_file" "api-gateway-target-lambda.zip" {
  type = "zip"
  source_file = "${path.module}/api-gateway-consumer-lambda.py"
  output_path = "${path.module}/api-gateway-consumer-lambda.zip"
}

resource "aws_lambda_function" "webhook" {
  function_name = "webhook-handler"
  role = aws_iam_role.lambda_exec.arn
  handler = "index_handler"
  runtime = "python3.14"
  filename = data.archive_file.api-gateway-target-lambda.zip.output_path
  architectures = ["arm64"]

  environment {
    variables = {
      WEBHOOK_SECRET = "replace-with-secret-or-use-secrets-manager"
    }
  }
}
