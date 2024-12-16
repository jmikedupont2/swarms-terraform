#   variable "provider_alias" {
#     type = any
#   }
variable  security_group_id    {} #   = local.name
variable  name    {} #   = local.name
variable  domain_name    {} #   = local.name
variable  vpc_id  {}  #= module.vpc.vpc_id
#variable  subnets {} #= module.vpc.public_subnets
variable  public_subnets {} #= module.vpc.public_subnets

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-alb"
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.12.0"
  name    = "${var.name}-api" # local.name
  vpc_id  = var.vpc_id # module.vpc.vpc_id
  subnets = var.public_subnets # module.vpc.public_subnets
  enable_deletion_protection = false
  create_security_group=false
  security_groups = [var.security_group_id]
  client_keep_alive = 7200
  tags = local.tags
}

resource "aws_route53_zone" "primary" {
   name = var.domain_name
}

resource "aws_route53_record" "api-cname" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "us-east-1.${var.domain_name}"
  type    = "CNAME"
  ttl     = 5

#  weighted_routing_policy {
#    weight = 10
#  }
  #set_identifier = "dev"
  records        = [
    module.alb.dns_name
  ]
}

data "cloudflare_zone" "zone" {
  #type   = "full"
  name   = "introspector.meme"
  account_id = "0ceffbadd0a04623896f5317a1e40d94"
}

resource "cloudflare_record" "aws-ns-record" {
  count = "${length(aws_route53_zone.primary.name_servers)}"
  #domain = "${var.domain_name}"
  name   = var.domain_name
  zone_id = data.cloudflare_zone.zone.id
  content = "${element(aws_route53_zone.primary.name_servers, count.index)}"
  type     = "NS"
  priority = 1
}

module "acm" {
#  count = 0
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"
  domain_name = var.domain_name
  zone_id     = aws_route53_zone.primary.zone_id
  subject_alternative_names = [
    "*.${var.domain_name}"
  ]
}

## now we just lift the listener code
resource "aws_lb_listener" "this" {
  port                        = 443
  protocol                    = "HTTPS"
  ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn             = module.acm.acm_certificate_arn
  load_balancer_arn = module.alb.arn
  #additional_certificate_arns = [module.wildcard_cert.acm_certificate_arn]
  #     #forward = {
  #       #target_group_key = "ex-swarms-instance"
  # 	target_group_arn = "ex-swarms-instance"
  # 	#target_group = []

  default_action {
    target_group_arn =aws_lb_target_group.this.arn
    #module.alb.target_groups["ex-lambda-with-trigger"].arn
    #length(try(default_action.value.target_groups, [])) > 0 ? null : try(default_action.value.arn, aws_lb_target_group.this[default_action.value.target_group_key].arn, null)
    type             = "forward"
  }
}


resource "aws_lb_target_group" "this" {
  name_prefix                       = "swarms"
  protocol                          = "HTTP"
  port                              = 80
  target_type                       = "instance"
  vpc_id = var.vpc_id
  deregistration_delay              = 10
  #load_balancing_algorithm_type     = "weighted_random"
  #load_balancing_anomaly_mitigation = "on"
  #load_balancing_cross_zone_enabled = false
  protocol_version = "HTTP1"
  #
  health_check {
    path = "/v1/docs" # the docs api
    enabled             = true
    healthy_threshold   = 10
    interval            = 130
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 120
    unhealthy_threshold = 10
  }
  
#  stickiness {
#    cookie_duration = 86400
#    enabled         = true
#    type            = "lb_cookie"
#  }
  
}

output zone_id {
  value = aws_route53_zone.primary.zone_id
}

output zone {
  value = aws_route53_zone.primary
}
output alb_target_group_arn {
  value = aws_lb_target_group.this.arn
}

output dns {
  value = module.alb.dns_name
}

output cname {
  value = aws_route53_record.api-cname.fqdn
}
