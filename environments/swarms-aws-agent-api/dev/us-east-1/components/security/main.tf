# Description: Terraform configuration for managing security groups.
# Author: <Your Name>
# Date: 2024-12-22

variable  vpc_id { }
variable  tags { }
variable  name { }

module "asg_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.name}-external"
  description = "external group"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = [
    "https-443-tcp",
    "http-80-tcp",
#    "ssh-tcp" dont need this now
  ]

  egress_rules = ["all-all"]

  tags = var.tags
}

module "asg_sg_internal" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.name}-internal"
  description = "An internal security group"
  vpc_id      = var.vpc_id
  # see ~/2024/12/13/terraform-aws-security-group/examples/complete/main.tf
  ingress_with_source_security_group_id = [  
    {
      rule        = "http-80-tcp",     
      # only allow from load balancer for security
      source_security_group_id = module.asg_sg.security_group_id 
    }
  ]
  egress_rules = ["all-all"]

  tags = var.tags
}

output "security_group_id" {
  value = module.asg_sg.security_group_id 
}

output "internal_security_group_id" {
  value = module.asg_sg_internal.security_group_id 
}


