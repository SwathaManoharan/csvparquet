import boto3
import os
import pandas as pd
import io
import pyarrow as pa
import pyarrow.parquet as pq

s3 = boto3.client('s3')
ses = boto3.client('ses')

dest_bucket = os.environ['DEST_BUCKET']
email = os.environ['EMAIL']

def lambda_handler(event, context):
    for record in event['Records']:
        src_bucket = record['s3']['bucket']['name']
        src_key = record['s3']['object']['key']

        # Get CSV from source bucket
        response = s3.get_object(Bucket=src_bucket, Key=src_key)
        csv_content = response['Body'].read().decode('utf-8')
        df = pd.read_csv(io.StringIO(csv_content))

        # Convert to Parquet
        table = pa.Table.from_pandas(df)
        parquet_buffer = io.BytesIO()
        pq.write_table(table, parquet_buffer)

        parquet_key = src_key.replace('.csv', '.parquet')

        # Upload to destination bucket (same as source in your case)
        s3.put_object(Bucket=dest_bucket, Key=parquet_key, Body=parquet_buffer.getvalue())

        # Send SES email
        ses.send_email(
            Source=email,
            Destination={'ToAddresses': [email]},
            Message={
                'Subject': {'Data': 'CSV Converted to Parquet'},
                'Body': {'Text': {'Data': f"{src_key} was successfully converted to {parquet_key} and uploaded."}}
            }
        )

    return {"statusCode": 200, "body": "Success"}
