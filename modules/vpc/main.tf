variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "swarms-vpc"
  cidr   = var.vpc_cidr
  azs    = var.azs
  private_subnets = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 4)]
  enable_nat_gateway = false
  tags = var.tags
}
