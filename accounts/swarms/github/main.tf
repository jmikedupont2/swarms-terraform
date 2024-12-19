
variable aws_region {}
variable aws_account_id {}

terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "6.4.0"
    }
  }
}

#data "github_actions_public_key" "public_key" {
#  repository       = "jmikedupont2/terraform-aws-oidc-github"
#}


resource "github_actions_secret" "region" {
  repository       = "terraform-aws-oidc-github"
  secret_name      = "AWS_REGION"
  plaintext_value  = var.aws_region
}

resource "github_actions_secret" "account" {
  repository       = "terraform-aws-oidc-github"
  secret_name = "AWS_ACCOUNT_ID"
  plaintext_value  = var.aws_account_id
}
