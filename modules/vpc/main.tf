# Description: Terraform configuration for managing VPCs.
# Author: <Your Name>
# Date: 2024-12-22

#from  https://github.com/terraform-aws-modules/terraform-aws-vpc

data "aws_availability_zones" "available" {}

locals {
  name   = "swarms"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    project    = local.name
#    GithubRepo = "terraform-aws-vpc"
#    GithubOrg  = "terraform-aws-modules"
  }
}

# resource "vpc" "swarms" {
#   source = "terraform-aws-modules/vpc/aws"
#   #source          = "https://github.com/terraform-aws-modules/terraform-aws-vpc.git"
#   name = "swarms"
#   cidr = "10.0.0.0/16"
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

#   enable_nat_gateway = true
#   enable_vpn_gateway = true

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#   }
# }

#  provider_name   = "aws"



################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../../../modules/vpc"
  vpc_cidr = local.vpc_cidr
  azs      = local.azs
  tags     = local.tags
}

# ################################################################################
# # VPC Endpoints Module
# ################################################################################

# module "vpc_endpoints" {
#   source = "../../modules/vpc-endpoints"

#   vpc_id = module.vpc.vpc_id

#   create_security_group      = true
#   security_group_name_prefix = "${local.name}-vpc-endpoints-"
#   security_group_description = "VPC endpoint security group"
#   security_group_rules = {
#     ingress_https = {
#       description = "HTTPS from VPC"
#       cidr_blocks = [module.vpc.vpc_cidr_block]
#     }
#   }

#   endpoints = {
#     s3 = {
#       service             = "s3"
#       private_dns_enabled = true
#       dns_options = {
#         private_dns_only_for_inbound_resolver_endpoint = false
#       }
#       tags = { Name = "s3-vpc-endpoint" }
#     },
#     dynamodb = {
#       service         = "dynamodb"
#       service_type    = "Gateway"
#       route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
#       policy          = data.aws_iam_policy_document.dynamodb_endpoint_policy.json
#       tags            = { Name = "dynamodb-vpc-endpoint" }
#     },
#     ecs = {
#       service             = "ecs"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ecs_telemetry = {
#       create              = false
#       service             = "ecs-telemetry"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#     },
#     ecr_api = {
#       service             = "ecr.api"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
#     },
#     ecr_dkr = {
#       service             = "ecr.dkr"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
#     },
#     rds = {
#       service             = "rds"
#       private_dns_enabled = true
#       subnet_ids          = module.vpc.private_subnets
#       security_group_ids  = [aws_security_group.rds.id]
#     },
#   }

#   tags = merge(local.tags, {
#     Project  = "Secret"
#     Endpoint = "true"
#   })
# }

# module "vpc_endpoints_nocreate" {
#   source = "../../modules/vpc-endpoints"

#   create = false
# }

# ################################################################################
# # Supporting Resources
# ################################################################################

# data "aws_iam_policy_document" "dynamodb_endpoint_policy" {
#   statement {
#     effect    = "Deny"
#     actions   = ["dynamodb:*"]
#     resources = ["*"]

#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     condition {
#       test     = "StringNotEquals"
#       variable = "aws:sourceVpc"

#       values = [module.vpc.vpc_id]
#     }
#   }
# }

# data "aws_iam_policy_document" "generic_endpoint_policy" {
#   statement {
#     effect    = "Deny"
#     actions   = ["*"]
#     resources = ["*"]

#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     condition {
#       test     = "StringNotEquals"
#       variable = "aws:SourceVpc"

#       values = [module.vpc.vpc_id]
#     }
#   }
# }

# resource "aws_security_group" "rds" {
#   name_prefix = "${local.name}-rds"
#   description = "Allow PostgreSQL inbound traffic"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     description = "TLS from VPC"
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     cidr_blocks = [module.vpc.vpc_cidr_block]
#   }

#   tags = local.tags
# }
output "vpc" {
value = module.vpc
}
