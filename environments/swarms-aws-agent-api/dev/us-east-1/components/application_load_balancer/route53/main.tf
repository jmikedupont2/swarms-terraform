variable "domain_name" {} #   = local.name
variable "alb_dns_name" {}
variable "alb_dns_zone" {}
data "aws_route53_zone" "primary" {
  name = var.domain_name
}

resource "aws_route53_record" "api-cname" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.domain_name
  #  type    = "CNAME"
  type = "A"
  #  ttl     = 5

  #  weighted_routing_policy {
  #    weight = 10
  #  }
  #set_identifier = "dev"
  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_dns_zone
    evaluate_target_health = true

    #
  }
}

resource "aws_route53_record" "api-cname-test" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "test.${var.domain_name}"
  type    = "CNAME"
  records = [aws_route53_record.api-cname.fqdn]
  ttl     = 300
}

resource "aws_route53_record" "api-cname-dev" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "dev.${var.domain_name}"
  type    = "CNAME"
  records = [aws_route53_record.api-cname.fqdn]
  ttl     = 300

}

output "cname" {
  value = aws_route53_record.api-cname.fqdn
}
output "zone" {
  value = data.aws_route53_zone.primary
}
output "primary_zone_id" {
  value = data.aws_route53_zone.primary.zone_id
}
