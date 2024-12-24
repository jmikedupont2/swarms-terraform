module "ssm" {
  #  source                    = "bridgecrewio/session-manager/aws"
  #  version                   = "0.4.2"
  source                   = "git::https://github.com/jmikedupont2/terraform-aws-session-manager.git?ref=master"
  bucket_name              = "swarms-session-logs"
  access_log_bucket_name   = "swarms-session-access-logs"
  enable_log_to_s3         = true
  enable_log_to_cloudwatch = true
  tags                     = { project = "swarms" }
  #linux_shell_profile      = "date"
}

#https://github.com/gazoakley/terraform-aws-session-manager-settings


resource "aws_cloudwatch_log_group" "app_signals" {
  for_each          = toset(["ec2", "eks", "generic", "k8s"])
  name              = "/aws/appsignals/${each.key}"
  retention_in_days = 30
  kms_key_id        = "arn:aws:kms:us-east-2:916723593639:key/cc8e1ee7-a05b-4642-bd81-ba5548635590"
}

resource "aws_cloudwatch_log_group" "app_signals2" {
  for_each          = toset(["data"])
  name              = "/aws/application-signals/${each.key}"
  retention_in_days = 30
  kms_key_id        = "arn:aws:kms:us-east-2:916723593639:key/cc8e1ee7-a05b-4642-bd81-ba5548635590"
}

# module "session-manager-settings" {
#   source  = "gazoakley/session-manager-settings/aws"
#   s3_bucket_name            = "swarms-session-logs-bucket"
#   cloudwatch_log_group_name = "/ssm/swarms-session-logs"
#   #kms_key_id = arn:aws:kms:us-east-2:916723593639:key/cc8e1ee7-a05b-4642-bd81-ba5548635590
#   kms_key_id = "cc8e1ee7-a05b-4642-bd81-ba5548635590"
# }
# Configure the AWS provider
# provider "aws" {
#   region = "us-east-2"  # Matching the region from your CloudTrail event
# }

# # Create or update the S3 bucket with tags
# resource "aws_s3_bucket" "session_logs" {
#   bucket = "swarms-session-logs-20241221151754799300000003"

#   # Force destroy can be set to true if you want to allow Terraform to delete the bucket even if it contains objects
#   force_destroy = false

#   tags = {
#     Environment = "Production"  # Example tag
#     Project     = "Swarms"      # Example tag
#     Created     = "2024-12-21"  # Example tag
#   }
# }

# # Add bucket versioning (recommended for logging buckets)
# resource "aws_s3_bucket_versioning" "session_logs_versioning" {
#   bucket = aws_s3_bucket.session_logs.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# # Add bucket encryption (recommended)
# resource "aws_s3_bucket_server_side_encryption_configuration" "session_logs_encryption" {
#   bucket = aws_s3_bucket.session_logs.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# # Add lifecycle rules (optional, but recommended for log buckets)
# resource "aws_s3_bucket_lifecycle_configuration" "session_logs_lifecycle" {
#   bucket = aws_s3_bucket.session_logs.id

#   rule {
#     id     = "log_retention"
#     status = "Enabled"

#     transition {
#       days          = 30
#       storage_class = "STANDARD_IA"
#     }

#     expiration {
#       days = 90  # Adjust retention period as needed
#     }
#   }
# }
