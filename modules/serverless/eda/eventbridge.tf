module "eventbridge" {
  source           = "terraform-aws-modules/eventbridge/aws"

  bus_name         = "allicator-event-bus"

  log_config = {
    include_detail = "FULL"
    level          = "INFO"
  }

  log_delivery = {
    cloudwatch_logs = {
        destination_arn = "arn:aws:logs:eu-west-2:851459781336:log-group:/aws/events/allicator-event-bus"
    }
    s3 = {
        destination_arn = "arn:aws:s3:::allicator-event-bus-logs"
    }
  }

  rules = {
    orders = {
        description     = "Capture all order data"
        event_pattern   = jsonencode({ "source" : ["myapp.orders"]})
        enabled         = true
    }
  }

  targets = {
    orders = [
      {
        name               = "send-orders-to-sqs"
        arn                = "aws_sqs_queue.queue.arn"
        dead_letter_arn    = "aws_sqs_queue.dlq.arn"
      },
      {
        name               = "send-orders-to-lambda"
        arn                = "<lambda arn>"
        dead_letter_arn    = "aws_sqs_queue.dlq.arn"
        input_transformer  = "<transformer>"
      },
      {
        name               = "send-orders-to-kinesis"
        arn                = "aws_kinesis_stream.orders.arn"
        dead_letter_arn    = "aws_sqs_queue.dlq.arn"
      },
      {
        name = "log-orders-to-cloudwatch"
        arn = aws_cloudwatch_log_group.this.arn
      }
    ]
  }

  tags = {
    Name = "allicator-event-bus"
  }
}