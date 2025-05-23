
# Source and Destination Buckets
resource "aws_s3_bucket" "source" {
  bucket = var.source_bucket_name
}

resource "aws_s3_bucket" "destination" {
  bucket = var.destination_bucket_name
}

# SES Email
resource "aws_ses_email_identity" "email" {
  email = var.notification_email
}

# IAM Role and Policy
resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.lambda_function_name}-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:PutObject"],
        Resource = [
          "arn:aws:s3:::${var.source_bucket_name}/*",
          "arn:aws:s3:::${var.destination_bucket_name}/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["ses:SendEmail", "ses:SendRawEmail"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["logs:*"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}


resource "aws_lambda_layer_version" "layer" {
  filename             = "layer.zip"
  source_code_hash     = filebase64sha256("layer.zip")
  layer_name           = "${var.layer_name}-pyarrow"
  compatible_runtimes  = [var.runtime]
}


# Lambda Function from zip
resource "aws_lambda_function" "csv_to_parquet" {
  filename      = "lambda_function_payload.zip"
  function_name = var.lambda_function_name
  runtime       = var.runtime
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn
  layers = [
    aws_lambda_layer_version.layer.arn
  ]


  environment {
    variables = {
      DEST_BUCKET = var.destination_bucket_name
      EMAIL       = var.notification_email
    }
  }
}



# Lambda permission for S3 trigger
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_to_parquet.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.source.arn
}

# S3 trigger
resource "aws_s3_bucket_notification" "notify" {
  bucket = aws_s3_bucket.source.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_to_parquet.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
