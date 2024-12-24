variable "vpc_id" {}
variable "security_group_id" {} #   = local.name
variable "name" {}              #   = local.name
variable "domain_name" {}
variable "public_subnets" {} #= module.vpc.public_subnets

data "aws_availability_zones" "available" {}

locals {
  name = "ex-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-alb"
  }
}

module "alb" {
  source                     = "terraform-aws-modules/alb/aws"
  version                    = "9.12.0"
  name                       = "${var.name}-api"  # local.name
  vpc_id                     = var.vpc_id         # module.vpc.vpc_id
  subnets                    = var.public_subnets # module.vpc.public_subnets
  enable_deletion_protection = false
  create_security_group      = false
  security_groups            = [var.security_group_id]
  client_keep_alive          = 7200
  tags                       = local.tags
}



output "dns" {
  value = module.alb.dns_name
}

module "route53" {
  source       = "./route53/"
  alb_dns_name = module.alb.dns_name
  alb_dns_zone = module.alb.zone_id
  domain_name  = var.domain_name
}

module "tg_prod" {
  source      = "./target_group/"
  name_prefix = "swarms"
  vpc_id      = var.vpc_id # module.vpc.vpc_id
}

module "tg_test" {
  source      = "./target_group/"
  name_prefix = "test"
  vpc_id      = var.vpc_id # module.vpc.vpc_id
}

module "tg_dev" {
  source      = "./target_group/"
  name_prefix = "dev"
  vpc_id      = var.vpc_id # module.vpc.vpc_id
}

module "https" {
  source = "./https/"
  #  vpc_id  = var.vpc_id # module.vpc.vpc_id
  zone_id               = module.route53.primary_zone_id
  domain_name           = var.domain_name
  alb_arn               = module.alb.arn
  prod_target_group_arn = module.tg_prod.alb_target_group_arn
  test_target_group_arn = module.tg_test.alb_target_group_arn
  dev_target_group_arn  = module.tg_dev.alb_target_group_arn
}


output "prod_alb_target_group_arn" {
  value = module.tg_prod.alb_target_group_arn
}

output "test_alb_target_group_arn" {
  value = module.tg_test.alb_target_group_arn
}

output "dev_alb_target_group_arn" {
  value = module.tg_dev.alb_target_group_arn
}
