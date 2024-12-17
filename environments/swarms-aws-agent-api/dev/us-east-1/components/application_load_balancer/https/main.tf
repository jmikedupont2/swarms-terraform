variable alb_arn{}
variable domain_name{}
variable zone_id{}
variable aws_lb_target_group_arn{}

module "acm" {
#  count = 0
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"
  domain_name = var.domain_name
  zone_id     = var.zone_id
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
  load_balancer_arn = var.alb_arn
  #additional_certificate_arns = [module.wildcard_cert.acm_certificate_arn]
  #     #forward = {
  #       #target_group_key = "ex-swarms-instance"
  # 	target_group_arn = "ex-swarms-instance"
  # 	#target_group = []

  default_action {
    target_group_arn =var.aws_lb_target_group_arn
    #module.alb.target_groups["ex-lambda-with-trigger"].arn
    #length(try(default_action.value.target_groups, [])) > 0 ? null : try(default_action.value.arn, aws_lb_target_group.this[default_action.value.target_group_key].arn, null)
    type             = "forward"
  }
}
