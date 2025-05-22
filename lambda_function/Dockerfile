FROM public.ecr.aws/lambda/python:3.9

COPY lambda_function.py ./

RUN pip install pandas pyarrow boto3 -t .

CMD ["lambda_function.lambda_handler"]
