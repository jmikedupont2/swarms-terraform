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
}
