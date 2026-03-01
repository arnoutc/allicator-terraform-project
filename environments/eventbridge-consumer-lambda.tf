data "archive_file" "eventbridge_consumer_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/eventbridge-consumer-lambda.py"
  output_path = "${path.module}/eventbridge-consumer-lambda.zip"
}

resource "aws_lambda_function" "consumer" {
  function_name = "webhook-event-consumer"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "eventbridge-consumer-lambda.lambda_handler"
  runtime       = "python3.14"
  filename      = data.archive_file.eventbridge_consumer_lambda_zip.output_path
  architectures = ["arm64"]

  environment {
    variables = {
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.bus.name
    }
  }

}