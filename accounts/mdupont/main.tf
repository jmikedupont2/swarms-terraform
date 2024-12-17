variable "google_oauth_client_secret" {}
variable "google_oauth_client_id" {} 

module ses {
  verify_dkim=true
  domain="introspector.meme" # put the mail at the top level
  #verify_domain =true
  verify_domain =false # not on aws
  group_name="introspector"
  source = "../../environments/swarms-aws-agent-api/dev/us-east-1/components/ses"
}

# module ses_verification {
#   verify_dkim=true
#   domain="introspector.meme" # put the mail at the top level
#   #verify_domain =true
#   verify_domain =false # not on aws
#   group_name="introspector"
#   source = "../../environments/swarms-aws-agent-api/dev/us-east-1/components/ses_verify"
# }

module cognito {
  aws_account  =var.aws_account_id
  myemail ="jmdupont"
  mydomain ="introspector"
  mydomain_suffix = "meme"
  #../../../17/
  aws_region = var.aws_region
  env={
    region = var.aws_region
    profile = var.profile
  }
  source = "../../environments/swarms-aws-agent-api/dev/us-east-1/components/cognito_user_pool"
  #source = "~/2024/12/17/cognito/terraform-aws-cognito-user-pool/examples/complete/"
  #source = "git::https://github.com/meta-introspector/terraform-aws-cognito-user-pool.git?ref=feature/meta-meme"
  google_oauth_client_secret=var.google_oauth_client_secret
  google_oauth_client_id=var.google_oauth_client_id
}
output cognito{
  value = module.cognito
  sensitive = true
}
