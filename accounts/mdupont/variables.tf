variable "project_name" {
  type    = string
  default = "swarms"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_account_id" {
  type    = string
  default = "767503528736"
}

variable "iam_user" {
  type    = string
  default = "mdupont"
}

variable "table_name" {
  type    = string
  default = "swarms"
}

variable "lock_resource" {
  type    = string
  default = "terraform/state/lock"
}

variable "partition" {
  type    = string
  default = "aws"
}

variable "logs_resource" {
  type    = string
  default = "aws_logs"
}

variable "permissions_check" {
  type    = string
  default = "config-permissions-check"
}

variable "delivery_service" {
  type    = string
  default = "delivery.logs.amazonaws.com"
}

variable "logging_service" {
  type    = string
  default = "logging.s3.amazonaws.com"
}
# swarms-tf-state-log-us-east-1
# swarms-tf-state-us-east-1
