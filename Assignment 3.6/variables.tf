variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "christanyk-package-scan-lambda-fn"
}

variable "iam_name" {
  description = "Name of the IAM role for Lambda"
  type        = string
  default     = "iam_package_scan_christanyk_lambda"
}

variable "aws_account_id" {
  description = "AWS Account ID for constructing CloudWatch log ARNs"
  type        = string
  default     = "255945442255"
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "christanyk-vpc-tf-module"
}

variable "created_by" {
  description = "Name of the creator"
  type        = string
  default     = "christanyk"
}
