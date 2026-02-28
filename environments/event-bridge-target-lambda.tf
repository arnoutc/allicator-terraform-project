data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "event_bridge_target_function.py"
  output_path = "event-bridge-target-lambda.zip"
}

resource "aws_lambda_function" "event-bridge-target-lambda" {
  filename         = "event-bridge-target-lambda.zip"
  function_name    = "event-bridge-target-lambda-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_handler"
  runtime          = "python3.14"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 15
  memory_size = 1024
  environment {
    variables = {
      PRODUCTION = false
    }
  }
}

resource "aws_lambda_function_url" "lambda" {
  function_name      = aws_lambda_function.event-bridge-target-lambda.function_name
  authorization_type = "NONE"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "event-bridge-target-lambda-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "lambda" {
  name = "event-bridge-target-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:logs:*:*:*"
      },
    ]
  })
}

