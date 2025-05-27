variable "lambda_function_name" {}
variable "bucket_name" {}
variable "lambda_exec_role_arn" {}

resource "aws_lambda_function" "stream_simulator" {
  filename         = "${path.module}/../../lambda_package.zip"
  function_name    = var.lambda_function_name
  role             = var.lambda_exec_role_arn
  handler          = "stream_simulator.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/../../lambda_package.zip")

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
    }
  }
}

resource "aws_cloudwatch_event_rule" "every_minute" {
  name                = "every-minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_minute.name
  target_id = "lambda"
  arn       = aws_lambda_function.stream_simulator.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stream_simulator.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.stream_simulator.function_name
}
