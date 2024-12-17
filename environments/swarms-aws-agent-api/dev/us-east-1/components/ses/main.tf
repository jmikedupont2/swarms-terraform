#variable "zone_id" {} # domain
variable "verify_domain" {}
variable "group_name" {}
variable "verify_dkim" {}
variable "domain" {} 

#resource "aws_route53_zone" "private_dns_zone" {
#  name = var.domain
#  tags = module.this.tags
#}

module "ses" {
  source = "git::https://github.com/cloudposse/terraform-aws-ses.git"
  domain        = var.domain
  #  zone_id       = var.zone_id
    zone_id       = aws_route53_zone.private_dns_zone.zone_id
  verify_dkim   = var.verify_dkim
  verify_domain = var.verify_domain
  ses_group_name = var.group_name
  context = module.this.context
  #ses_group_enabled = false
  ses_user_enabled = false
}
