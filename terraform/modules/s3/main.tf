variable "bucket_name" {}

resource "aws_s3_bucket" "data_bucket" {
  bucket = var.bucket_name

  versioning {
    enabled = true
  }


  tags = {
    Name        = "StreamSimDataBucket"
    Environment = "Dev"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.data_bucket.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.data_bucket.arn
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

