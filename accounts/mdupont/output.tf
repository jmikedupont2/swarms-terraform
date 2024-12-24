output "aws_region" {
  value = var.aws_region
}

output "iam_user" {
  value = var.iam_user
}

output "table_name" {
  value = var.table_name
}

output "project_name" {
  value = var.project_name
}

output "aws_caller_identity_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_s3_bucket_logging_name" {
  value = data.aws_s3_bucket.terraform_logging.bucket
}

output "aws_s3_bucket_state_name" {
  value = data.aws_s3_bucket.terraform_state.bucket
}

output "aws_cloudtrail_service_account_id" {
  value = data.aws_cloudtrail_service_account.main.id
}


