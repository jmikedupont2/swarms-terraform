variable alb_arn{}
variable domain_name{}
variable zone_id{}
variable aws_lb_target_group_arn{}
variable new_target_group_arn{}

module "acm" {
#  count = 0
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"
  domain_name = var.domain_name
  zone_id     = var.zone_id
  #wait_for_validation = false
  subject_alternative_names = [
    "*.${var.domain_name}"
  ]
}

## add a rule for matching urls for /v1/<user>/<agent>/<api> and routing that to a new target group
#like var.aws_lb_target_group{ { user, agent, api, target group name}}
resource "aws_lb_listener" "this" {
  port                        = 443
  protocol                    = "HTTPS"
  ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn             = module.acm.acm_certificate_arn
  load_balancer_arn = var.alb_arn
  default_action {
    target_group_arn =var.aws_lb_target_group_arn
    type             = "forward"
  }
}

# make a new one for checking for ?customer=name in the rules instead of the path
resource "aws_lb_listener_rule" "route_v1_api" {
  listener_arn = aws_lb_listener.this.arn
  priority     = 100  # Set priority as needed, must be unique

  action {
    type             = "forward"
    target_group_arn = var.new_target_group_arn  # New target group's ARN
  }

  condition {
    path_pattern {
      values = ["/v1/*/*/*"]
    }
  }
}


resource "aws_lb_listener_rule" "route_v1_api_customer" {
  listener_arn = aws_lb_listener.this.arn
  priority     = 200  # Set priority as needed, must be unique

  action {
    type             = "forward"
    target_group_arn = var.new_target_group_arn  # New target group's ARN
  }

  condition {
    query_string {
      key = "customer"
      value ="test"
    }
  }
}

resource "aws_lb_listener" "insecure" {
  port                        = 80
  protocol                    = "HTTP"
  load_balancer_arn = var.alb_arn
  default_action {
    target_group_arn =var.aws_lb_target_group_arn
    type             = "forward"
  }
}
