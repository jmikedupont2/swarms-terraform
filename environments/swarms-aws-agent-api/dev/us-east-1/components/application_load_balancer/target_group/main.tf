variable  vpc_id  {} 
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
output alb_target_group_arn {
  value = aws_lb_target_group.this.arn
}
