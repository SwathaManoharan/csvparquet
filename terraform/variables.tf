variable "aws_region" {}
variable "source_bucket_name" {}
variable "destination_bucket_name" {}
variable "lambda_function_name" {}

variable "lambda_handler" {
  default = "lambda_function.lambda_handler"
}

variable "runtime" {
  default = "python3.9"
}

variable "notification_email" {}

variable "lambda_s3_bucket" {}
variable "lambda_s3_key" {}
variable "layer_s3_key" {}
variable "lambda_layer_name" {}