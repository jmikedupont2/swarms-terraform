variable "google_oauth_client_secret" {}
variable "google_oauth_client_id" {} 

module ses {
  verify_dkim=true
  # use another domain for the email so we dont have the root on ses yet
  domain="mail.introspector.meme"
  verify_domain =true
  group_name="introspector"
  source = "../../environments/swarms-aws-agent-api/dev/us-east-1/components/ses"
}

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
