variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "artifact_bucket" {
  description = "S3 bucket to store Lambda code and layer zips"
  type        = string
}

variable "source_bucket_name" {
  description = "Source S3 bucket name"
  type        = string
}

variable "destination_bucket_name" {
  description = "Destination S3 bucket name"
  type        = string
}

variable "notification_email" {
  description = "SES verified email for notifications"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "lambda_handler" {
  description = "Lambda handler (file.function)"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.9"
}

variable "layer_name" {
  description = "Lambda layer name"
  type        = string
}

variable "layer_s3_key" {
  description = "S3 key for the Lambda layer zip"
  type        = string
  default     = "layer.zip"
}

variable "code_s3_key" {
  description = "S3 key for the Lambda function zip"
  type        = string
  default     = "lambda.zip"
}
variable "artifact_bucket_name" {
  description = "S3 bucket name for storing Lambda artifacts"
  type        = string
}

