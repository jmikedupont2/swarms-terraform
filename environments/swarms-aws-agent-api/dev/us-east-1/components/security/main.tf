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

  name        = "${local.name}-external"
  description = "external group"
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

module "asg_sg_internal" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.name}-internal"
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

  tags = local.tags
}

output "security_group_id" {
  value = module.asg_sg.security_group_id 
}

output "internal_security_group_id" {
  value = module.asg_sg_internal.security_group_id 
}


