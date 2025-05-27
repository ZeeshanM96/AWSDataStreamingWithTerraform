import boto3
import os
import random
import csv
import io
from datetime import datetime

s3 = boto3.client('s3')
BUCKET_NAME = os.environ['BUCKET_NAME']
FILE_NAME = f"machine_data/{datetime.utcnow().strftime('%Y-%m-%dT%H-%M-%S')}.csv"


# Simulate one data point
def generate_machine_data():
    return [
        datetime.utcnow().isoformat(),
        round(random.uniform(20.0, 100.0), 2),
        round(random.uniform(1.0, 10.0), 2),
        round(random.uniform(0.0, 5.0), 2),
        random.randint(1000, 5000),
        random.choice(["OK", "WARN", "ERROR"])
    ]

def lambda_handler(event, context):
    output = io.StringIO()
    writer = csv.writer(output)

    # Write NO header — Athena knows the schema already

    # Generate and write 50 records
    for _ in range(50):
        writer.writerow(generate_machine_data())

    new_csv_data = output.getvalue()

    # Try to fetch existing file from S3
    try:
        existing_obj = s3.get_object(Bucket=BUCKET_NAME, Key=FILE_NAME)
        existing_csv_data = existing_obj['Body'].read().decode('utf-8')
    except s3.exceptions.NoSuchKey:
        existing_csv_data = ""

    # Append new data to existing data
    final_csv_data = existing_csv_data.rstrip('\n') + '\n' + new_csv_data.lstrip('\n')

    # Upload back to S3
    s3.put_object(
        Bucket=BUCKET_NAME,
        Key=FILE_NAME,
        Body=final_csv_data,
        ContentType='text/csv'
    )

    return {
        "statusCode": 200,
        "body": f"Appended 50 records to {FILE_NAME}"
    }
