# Terraform Modules

This directory contains reusable Terraform modules for AWS infrastructure deployment.

## Available Modules

### Cognito Module

Production-ready AWS Cognito User Pool module with enhanced security features.

#### Usage

```hcl
module "cognito" {
  source = "./modules/cognito"

  # Required variables
  application    = "my-app"
  environment    = "prod"
  region         = "us-east-1"
  domain_name    = "auth.example.com"
  portal_domain  = "app.example.com"
  
  # Optional variables with default values
  refresh_token_validity = 90
  auth_session_validity = 3
  access_token_validity = 1
  id_token_validity    = 1
  
  # Token validity units
  refresh_token_unit   = "days"
  access_token_unit    = "hours"
  id_token_unit       = "hours"
  
  tags = {
    Owner       = "DevOps"
    CostCenter  = "123456"
  }
}
```

#### Required Variables

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| application | Name of the application | `string` | yes |
| environment | Environment name (prod, staging, dev) | `string` | yes |
| region | AWS region for Cognito resources | `string` | yes |
| domain_name | Domain name for Cognito User Pool | `string` | yes |
| portal_domain | Domain name for the portal application | `string` | yes |

#### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| refresh_token_validity | Time until refresh token expires | `number` | `90` |
| auth_session_validity | Time until auth session expires (minutes) | `number` | `3` |
| access_token_validity | Time until access token expires | `number` | `1` |
| id_token_validity | Time until ID token expires | `number` | `1` |
| refresh_token_unit | Time unit for refresh token | `string` | `"days"` |
| access_token_unit | Time unit for access token | `string` | `"hours"` |
| id_token_unit | Time unit for ID token | `string` | `"hours"` |
| tags | Additional resource tags | `map(string)` | `{}` |

#### Outputs

| Name | Description |
|------|-------------|
| user_pool_id | The ID of the Cognito User Pool |
| user_pool_arn | The ARN of the Cognito User Pool |
| client_id | The ID of the Cognito User Pool Client |
| client_secret | The Client Secret of the Cognito User Pool Client |
| domain_name | The domain name of the Cognito User Pool |
| cognito_endpoints | Map of Cognito endpoints (authorization, token, userinfo, logout) |
| cognito_clientID_arn | ARN of the SSM Parameter storing the Client ID |
| cognito_clientsecret_arn | ARN of the SSM Parameter storing the Client Secret |
| cognito_signOut_Url | ARN of the SSM Parameter storing the Sign Out URL |

#### Features

- Enhanced password policy (12 chars minimum, mixed case, numbers, symbols)
- Multi-factor authentication (MFA) support
- Advanced security mode with risk-based authentication
- Customizable email and SMS templates
- OAuth 2.0 / OpenID Connect support
- CloudWatch logging integration
- Comprehensive tagging strategy
- SSM Parameter Store integration for secrets

#### Security Features

- Risk-based adaptive authentication
- Compromised credentials protection
- CloudWatch logging for monitoring
- Account recovery via email and phone
- Token revocation support
- Secure token configuration

For more detailed information about each module, please refer to the module's individual documentation in their respective directories.
