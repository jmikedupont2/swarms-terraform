variable  vpc_id {
  default = "vpc-04f28c9347af48b55"
}

locals {
  ami = "ami-0e2c8caa4b6378d8c"
  name   = "swarms"
  region = "us-east-1"
  ec2_subnet_id = "subnet-057c90cfe7b2e5646"

  tags = {
    project="swarms"
  }

}

module "asg_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "A security group"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = [
    "https-443-tcp",
    "http-80-tcp",
#    "ssh-tcp" dont need this now
  ]

  egress_rules = ["all-all"]

  tags = local.tags
}

output "security_group_id" {
  value = module.asg_sg.security_group_id 
}


# tofu state show module.security.module.asg_sg.aws_security_group.this_name_prefix[0]
# resource "aws_security_group" "this_name_prefix" {
#     arn                    = "arn:aws:ec2:us-east-1:767503528736:security-group/sg-03c9752b62d0bcfe4"
#     description            = "A security group"
#     egress                 = [
#         {
#             cidr_blocks      = [
#                 "0.0.0.0/0",
#             ]
#             description      = "All protocols"
#             from_port        = 0
#             ipv6_cidr_blocks = [
#                 "::/0",
#             ]
#             prefix_list_ids  = []
#             protocol         = "-1"
#             security_groups  = []
#             self             = false
#             to_port          = 0
#         },
#     ]
#     id                     = "sg-03c9752b62d0bcfe4"
#     ingress                = [
#         {
#             cidr_blocks      = [
#                 "0.0.0.0/0",
#             ]
#             description      = "HTTP"
#             from_port        = 80
#             ipv6_cidr_blocks = []
#             prefix_list_ids  = []
#             protocol         = "tcp"
#             security_groups  = []
#             self             = false
#             to_port          = 80
#         },
#         {
#             cidr_blocks      = [
#                 "0.0.0.0/0",
#             ]
#             description      = "HTTPS"
#             from_port        = 443
#             ipv6_cidr_blocks = []
#             prefix_list_ids  = []
#             protocol         = "tcp"
#             security_groups  = []
#             self             = false
#             to_port          = 443
#         },
#         {
#             cidr_blocks      = [
#                 "0.0.0.0/0",
#             ]
#             description      = "SSH"
#             from_port        = 22
#             ipv6_cidr_blocks = []
#             prefix_list_ids  = []
#             protocol         = "tcp"
#             security_groups  = []
#             self             = false
#             to_port          = 22
#         },
#     ]
#     name                   = "swarms-20241214133959057000000001"
#     name_prefix            = "swarms-"
#     owner_id               = "767503528736"
#     revoke_rules_on_delete = false
#     tags                   = {
#         "Name"    = "swarms"
#         "project" = "swarms"
#     }
#     tags_all               = {
#         "Name"    = "swarms"
#         "project" = "swarms"
#     }
#     vpc_id                 = "vpc-04f28c9347af48b55"

#     timeouts {
#         create = "10m"
#         delete = "15m"
#     }
# }
