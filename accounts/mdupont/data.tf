# task create an output file for this module to expose all interesting data, include the ids of each resource.
provider "aws" {
  region = var.aws_region
}

data "aws_iam_user" "example_user" {
  user_name = var.iam_user
}

#data "aws_dynamodb_table" "terraform_dynamo_table" {
#  name = var.table_name
#}


# Data resource for AWS call identity
data "aws_caller_identity" "current" {}

#data "aws_s3_bucket" "terraform_logging" {
#  bucket = "${var.project_name}-tf-state-log-${var.aws_region}"
#}

#data "aws_s3_bucket" "terraform_state" {
#  bucket = "${var.project_name}-tf-state-${var.aws_region}"
#}

#data "aws_cloudtrail_service_account" "main" {}
