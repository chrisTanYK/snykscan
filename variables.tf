variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  default     = "python3.9" # or "nodejs20.x"
}

variable "lambda_handler" {
  description = "Lambda handler"
  default     = "main.lambda_handler" # or "index.handler" for Nodejs
}