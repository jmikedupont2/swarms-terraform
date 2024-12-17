
# credentials

set up ~/.aws/credentials
```
[swarms]
aws_access_key_id =${your key}
aws_secret_access_key=${your SECRET}
```

# install opentofu or terraform
# install aws cli
# install aws ssm plugin

# create openai secret token

TODO:
`aws ssm set-parameter     --name "swarms_openai_key"`

# tofu init
# tofu plan
# tofu apply
point the dns api.swarms.ai at the dns servers in godaddy

`tofu state show module.swarms_api.module.alb.module.route53.data.aws_route53_zone.primary`

```terraform
# module.swarms_api.module.alb.module.route53.data.aws_route53_zone.primary:
data "aws_route53_zone" "primary" {
    arn                       = "arn:aws:route53:::hostedzone/Z04162952OP7P14Z97UWY"
    caller_reference          = "937599df-113d-4b02-8c75-4a20f8e6293e"
    id                        = "Z04162952OP7P14Z97UWY"
    name                      = "api.swarms.ai"
    name_servers              = [
        "ns-864.awsdns-44.net",
        "ns-1595.awsdns-07.co.uk",
        "ns-1331.awsdns-38.org",
        "ns-463.awsdns-57.com",
    ]
    primary_name_server       = "ns-864.awsdns-44.net"
    private_zone              = false
    resource_record_set_count = 3
    tags                      = {}
    zone_id                   = "Z04162952OP7P14Z97UWY"
}
```
so we need 4 records

1. NS api -> "ns-864.awsdns-44.net"
2. NS api -> "ns-1595.awsdns-07.co.uk"
3. NS api -> "ns-1331.awsdns-38.org"
4. NS api -> "ns-463.awsdns-57.com"

see youtube or 
https://youtu.be/3BI6_gq-lSU
https://dev.to/diegop0s/managing-your-godaddy-domain-with-route53-5f2p

# tofu apply

`tofu apply`
