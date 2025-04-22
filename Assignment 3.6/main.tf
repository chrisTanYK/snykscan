provider "aws" {
  region = "us-east-1"
}

# IAM Assume Role Policy for Lambda
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

# IAM Role Resource
resource "aws_iam_role" "iam_for_lambda" {
  name               = var.iam_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# CloudWatch Logs Inline Policy
data "aws_iam_policy_document" "inline_policy_cloudwatch" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:us-east-1:${var.aws_account_id}:log-group:/aws/lambda/${var.lambda_function_name}:*"
    ]
  }
}

# Attach CloudWatch Logs Policy to the Role
resource "aws_iam_role_policy" "lambda_logs_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.inline_policy_cloudwatch.json
}

# Lambda Function Resource (Python)
resource "aws_lambda_function" "own_lambda" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  timeout = 10
}
