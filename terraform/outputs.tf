output "bucket_name" {
  value = module.s3.bucket_name
}

output "lambda_function_name" {
  value = module.lambda.lambda_function_name
}

output "glue_table" {
  value = "machine_data"
}
