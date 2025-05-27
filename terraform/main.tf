provider "aws" {
  region = var.aws_region
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}

module "roles" {
  source      = "./modules/roles"
  bucket_arn  = module.s3.bucket_arn
}

module "lambda" {
  source                = "./modules/lambda"
  lambda_function_name  = var.lambda_function_name
  bucket_name           = module.s3.bucket_name
  lambda_exec_role_arn  = module.roles.lambda_exec_role_arn
}

module "glue" {
  source      = "./modules/glue"
  bucket_name = module.s3.bucket_name
}
