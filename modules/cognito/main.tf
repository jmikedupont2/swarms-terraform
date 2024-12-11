data "aws_caller_identity" "current" {}

resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.application}-${var.environment}-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email", "phone_number"]
  
  # Enhanced password policy
  password_policy {
    minimum_length                   = 12
    require_lowercase               = true
    require_numbers                 = true
    require_symbols                 = true
    require_uppercase               = true
    temporary_password_validity_days = 7
  }

  # Improved verification message template
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "${var.application} - Account Confirmation"
    email_message        = "Thank you for registering. Your confirmation code is {####}"
    sms_message          = "Your ${var.application} verification code is {####}"
  }

  # Enhanced schema with additional attributes
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 3
      max_length = 256
    }
  }

  schema {
    name                = "given_name"
    attribute_data_type = "String"
    mutable            = true
    required           = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                = "family_name"
    attribute_data_type = "String"
    mutable            = true
    required           = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # Enhanced SMS configuration
  sms_configuration {
    external_id    = "${var.application}-${var.environment}-sms"
    sns_caller_arn = aws_iam_role.iam_for_sms_cognito.arn
    sns_region     = var.region
  }

  # Advanced security configuration
  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  # Enhanced MFA configuration
  mfa_configuration = "ON"

  software_token_mfa_configuration {
    enabled = true
  }

  # Account recovery settings
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  # Admin create user config
  admin_create_user_config {
    allow_admin_create_user_only = false
    
    invite_message_template {
      email_subject = "Welcome to ${var.application}"
      email_message = "Your username is {username} and temporary password is {####}. Please change your password when you first log in."
      sms_message   = "Your username is {username} and temporary password is {####}"
    }
  }

  lambda_config {
    pre_sign_up = aws_lambda_function.lambda_function.arn
    
    # Additional Lambda triggers for enhanced security
    pre_authentication  = try(aws_lambda_function.pre_auth[0].arn, null)
    post_authentication = try(aws_lambda_function.post_auth[0].arn, null)
    pre_token_generation = try(aws_lambda_function.pre_token[0].arn, null)
  }

  depends_on = [aws_lambda_function.lambda_function, aws_iam_role.iam_for_sms_cognito]

  deletion_protection = "ACTIVE"

  # Enhanced tagging strategy
  tags = merge(
    {
      Name        = "${var.application}-${var.environment}-user-pool"
      Environment = var.environment
      Application = var.application
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

resource "aws_cognito_user_pool_client" "client" {
  name = "${var.application}-${var.environment}-client"

  user_pool_id                  = aws_cognito_user_pool.user_pool.id
  generate_secret               = true
  refresh_token_validity        = var.refresh_token_validity
  prevent_user_existence_errors = "ENABLED"
  
  # Enhanced auth flows
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]

  # Production URLs
  callback_urls                = ["https://${var.portal_domain}/signin-oidc"]
  logout_urls                  = ["https://${var.portal_domain}/sign-out"]
  supported_identity_providers = ["COGNITO"]

  # Token validity configuration
  auth_session_validity = var.auth_session_validity
  access_token_validity = var.access_token_validity
  id_token_validity     = var.id_token_validity
  
  token_validity_units {
    access_token  = var.access_token_unit
    id_token      = var.id_token_unit
    refresh_token = var.refresh_token_unit
  }

  # OAuth configuration
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "phone", "profile"]

  # Enable token revocation
  enable_token_revocation = true

  # Read timeout configuration
  read_attributes = [
    "email",
    "email_verified",
    "phone_number",
    "phone_number_verified",
    "given_name",
    "family_name"
  ]

  write_attributes = [
    "email",
    "phone_number",
    "given_name",
    "family_name"
  ]
}

resource "aws_cognito_user_pool_domain" "cognito-domain" {
  domain       = var.domain_name
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

data "aws_iam_policy_document" "assume_role_sms" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cognito-idp.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    # condition {
    #   test     = "ArnLike"
    #   variable = "aws:SourceArn"
    #   values   = [aws_cognito_user_pool.user_pool.arn]
    # }
  }
}

resource "aws_iam_role" "iam_for_sms_cognito" {
  name               = "iam_for_sms_cognito"
  assume_role_policy = data.aws_iam_policy_document.assume_role_sms.json

  tags = {
    application = var.application
  }
}

resource "aws_iam_role_policy_attachment" "cognito-sns" {
  role       = aws_iam_role.iam_for_sms_cognito.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

# Add CloudWatch logging
resource "aws_cloudwatch_log_group" "cognito_logs" {
  name              = "/aws/cognito/${var.application}-${var.environment}"
  retention_in_days = 30
  
  tags = merge(
    {
      Name        = "${var.application}-${var.environment}-cognito-logs"
      Environment = var.environment
      Application = var.application
      ManagedBy   = "terraform"
    },
    var.tags
  )
}
