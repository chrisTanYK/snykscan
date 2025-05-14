terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_lambda_function" "hello_world" {
  function_name = "helloWorld"
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  role          = aws_iam_role.lambda_exec.arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}
resource "random_id" "role_suffix" {
  byte_length = 4
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role_${random_id.role_suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

data "archive_file" "app_py.zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/hello-world"
  output_path = "${path.module}/lambda/hello-world.zip"
}
