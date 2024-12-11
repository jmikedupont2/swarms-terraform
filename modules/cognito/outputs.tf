output "user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.user_pool.id
}

output "user_pool_arn" {
  description = "The ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.user_pool.arn
}

output "client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.client.id
}

output "client_secret" {
  description = "The Client Secret of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.client.client_secret
  sensitive   = true
}

output "domain_name" {
  description = "The domain name of the Cognito User Pool"
  value       = aws_cognito_user_pool_domain.cognito-domain.domain
}

output "domain_aws_account_id" {
  description = "The AWS account ID for the Cognito User Pool domain"
  value       = aws_cognito_user_pool_domain.cognito-domain.aws_account_id
}

output "domain_cloudfront_distribution" {
  description = "The CloudFront distribution ID for the Cognito User Pool domain"
  value       = aws_cognito_user_pool_domain.cognito-domain.cloudfront_distribution_arn
}

output "cognito_endpoints" {
  description = "The endpoints for the Cognito User Pool"
  value = {
    authorization = "https://${aws_cognito_user_pool_domain.cognito-domain.domain}.auth.${var.region}.amazoncognito.com/oauth2/authorize"
    token        = "https://${aws_cognito_user_pool_domain.cognito-domain.domain}.auth.${var.region}.amazoncognito.com/oauth2/token"
    userinfo     = "https://${aws_cognito_user_pool_domain.cognito-domain.domain}.auth.${var.region}.amazoncognito.com/oauth2/userInfo"
    logout       = "https://${aws_cognito_user_pool_domain.cognito-domain.domain}.auth.${var.region}.amazoncognito.com/logout"
  }
}

# SSM Parameter outputs for secure storage
output "cognito_clientID_arn" {
  description = "The ARN of the SSM Parameter storing the Client ID"
  value       = aws_ssm_parameter.clientid.arn
}

output "cognito_clientsecret_arn" {
  description = "The ARN of the SSM Parameter storing the Client Secret"
  value       = aws_ssm_parameter.clientsecret.arn
}

output "cognito_signOut_Url" {
  description = "The ARN of the SSM Parameter storing the Sign Out URL"
  value       = aws_ssm_parameter.signOutUrl.arn
}