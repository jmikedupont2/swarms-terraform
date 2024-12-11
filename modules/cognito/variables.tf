variable "rds_arn" {
  description = "The ARN of the RDS instance for Lambda function access"
  type        = string
}

variable "security_groups_id" {
  description = "List of security group IDs for Lambda function"
  type        = list(string)
}

variable "subnets_id" {
  description = "List of subnet IDs for Lambda function"
  type        = list(string)
}

variable "portal_domain" {
  description = "The domain name for the portal application"
  type        = string
}

variable "domain_name" {
  description = "The domain name for Cognito user pool"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$", var.domain_name))
    error_message = "Domain name must be a valid domain name format."
  }
}

variable "refresh_token_validity" {
  description = "Time until the refresh token expires"
  type        = number
  default     = 90
  validation {
    condition     = var.refresh_token_validity >= 1 && var.refresh_token_validity <= 365
    error_message = "Refresh token validity must be between 1 and 365."
  }
}

variable "auth_session_validity" {
  description = "Time until the auth session expires (in minutes)"
  type        = number
  default     = 3
  validation {
    condition     = var.auth_session_validity >= 3 && var.auth_session_validity <= 15
    error_message = "Auth session validity must be between 3 and 15 minutes."
  }
}

variable "access_token_validity" {
  description = "Time until the access token expires"
  type        = number
  default     = 1
  validation {
    condition     = var.access_token_validity >= 1 && var.access_token_validity <= 24
    error_message = "Access token validity must be between 1 and 24 hours."
  }
}

variable "id_token_validity" {
  description = "Time until the ID token expires"
  type        = number
  default     = 1
  validation {
    condition     = var.id_token_validity >= 1 && var.id_token_validity <= 24
    error_message = "ID token validity must be between 1 and 24 hours."
  }
}

variable "refresh_token_unit" {
  description = "Time unit for refresh token validity"
  type        = string
  default     = "days"
  validation {
    condition     = contains(["seconds", "minutes", "hours", "days"], var.refresh_token_unit)
    error_message = "Refresh token unit must be one of: seconds, minutes, hours, days."
  }
}

variable "access_token_unit" {
  description = "Time unit for access token validity"
  type        = string
  default     = "hours"
  validation {
    condition     = contains(["seconds", "minutes", "hours", "days"], var.access_token_unit)
    error_message = "Access token unit must be one of: seconds, minutes, hours, days."
  }
}

variable "id_token_unit" {
  description = "Time unit for ID token validity"
  type        = string
  default     = "hours"
  validation {
    condition     = contains(["seconds", "minutes", "hours", "days"], var.id_token_unit)
    error_message = "ID token unit must be one of: seconds, minutes, hours, days."
  }
}

variable "application" {
  description = "Name of the application for resource tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
  validation {
    condition     = contains(["prod", "staging", "dev"], var.environment)
    error_message = "Environment must be one of: prod, staging, dev."
  }
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region for Cognito resources"
  type        = string
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.region))
    error_message = "Region must be a valid AWS region (e.g., eu-west-1, us-east-1)"
  }
}
