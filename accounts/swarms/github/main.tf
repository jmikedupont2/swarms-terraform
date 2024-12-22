# Description: Terraform configuration for managing GitHub actions secrets.
# Author: <Your Name>
# Date: 2024-12-22

variable aws_region {}
variable aws_account_id {}
variable repos {}

terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "6.4.0"
    }
  }
}

resource "github_actions_secret" "region" {
  for_each = var.repos
  repository       = each.key #
  secret_name      = "AWS_REGION"
  plaintext_value  = var.aws_region
}

resource "github_actions_secret" "account" {
  for_each = var.repos
  repository       = each.key
  secret_name = "AWS_ACCOUNT_ID"
  plaintext_value  = var.aws_account_id
}
