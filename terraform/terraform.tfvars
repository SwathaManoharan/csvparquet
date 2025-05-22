aws_region              = "ap-south-1"
source_bucket_name      = "swatha-source-bucket"
destination_bucket_name = "swatha-destination-bucket"
notification_email      = "swatha.manoharan@bootlabstech.com"
lambda_function_name    = "csv-to-parquet-fn"
runtime                 = "python3.9"
layer_name              = "zippedlayer"

