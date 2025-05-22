import boto3
import os
import io
import pyarrow.csv as pv
import pyarrow.parquet as pq

s3 = boto3.client('s3')
ses = boto3.client('ses')

dest_bucket = os.environ['DEST_BUCKET']
email = os.environ['EMAIL']

def lambda_handler(event, context):
    for record in event['Records']:
        src_bucket = record['s3']['bucket']['name']
        src_key = record['s3']['object']['key']

        # Download CSV from S3
        response = s3.get_object(Bucket=src_bucket, Key=src_key)
        csv_content = response['Body'].read()

        # Convert CSV to Arrow Table (without pandas)
        table = pv.read_csv(io.BytesIO(csv_content))

        # Convert to Parquet
        parquet_buffer = io.BytesIO()
        pq.write_table(table, parquet_buffer)

        # Create new key with .parquet extension
        parquet_key = src_key.rsplit('.', 1)[0] + '.parquet'

        # Upload to destination bucket
        s3.put_object(Bucket=dest_bucket, Key=parquet_key, Body=parquet_buffer.getvalue())

        # Send SES notification
        ses.send_email(
            Source=email,
            Destination={'ToAddresses': [email]},
            Message={
                'Subject': {'Data': 'CSV Converted to Parquet'},
                'Body': {'Text': {'Data': f"{src_key} was successfully converted to {parquet_key} and uploaded."}}
            }
        )

    return {"statusCode": 200, "body": "Success"}
