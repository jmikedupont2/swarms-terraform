#variable "dns_name" {} 
#variable "account_id" {}
# data "cloudflare_zone" "zone" {
#   count =0
#   name   = var.dns_name
#   account_id = var.account_id
# }

# resource "cloudflare_record" "aws-ns-record" {
#   count = 0
# #  count = "${length(aws_route53_zone.primary.name_servers)}"
#   #domain = "${var.domain_name}"
#   name   = var.domain_name
# #  zone_id = data.cloudflare_zone[0].zone.id
#   content = "${element(aws_route53_zone.primary.name_servers, count.index)}"
#   type     = "NS"
#   priority = 1
# }
