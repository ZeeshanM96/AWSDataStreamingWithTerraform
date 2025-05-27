import json
import boto3
import os

s3 = boto3.client('s3')
firehose = boto3.client('firehose')
FIREHOSE_STREAM = os.environ['FIREHOSE_STREAM']

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        response = s3.get_object(Bucket=bucket, Key=key)
        data = json.loads(response['Body'].read())

        for item in data:
            firehose.put_record(
                DeliveryStreamName=FIREHOSE_STREAM,
                Record={'Data': json.dumps(item) + '\n'}
            )

    return {
        'statusCode': 200,
        'body': f"Pushed {len(data)} records to Firehose"
    }
