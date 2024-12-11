resource "aws_ssm_parameter" "clientid" {
  name  = "Cognito_ClientID"
  type  = "SecureString"
  value = aws_cognito_user_pool_client.client.id

  tags = {
    application = var.application
  }
}

resource "aws_ssm_parameter" "clientsecret" {
  name  = "Cognito_Client_Secret"
  type  = "SecureString"
  value = aws_cognito_user_pool_client.client.client_secret

  tags = {
    application = var.application
  }
}

resource "aws_ssm_parameter" "signOutUrl" {
  name  = "Cognito_SignOut_Url"
  type  = "SecureString"
  value = "https://${aws_cognito_user_pool_domain.cognito-domain.domain}.auth.eu-west-2.amazoncognito.com/logout?client_id=${aws_cognito_user_pool_client.client.id}&logout_uri=https://${var.portal_domain}/sign-out"

  tags = {
    application = var.application
  }
}

