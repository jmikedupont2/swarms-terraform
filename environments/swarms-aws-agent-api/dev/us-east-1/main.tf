locals {
  #  instance_type = "t3.large"
  instance_type = "t3.medium"
  ami = "ami-0e2c8caa4b6378d8c"
  name   = "swarms"
  region = "us-east-1"
  ec2_subnet_id = "subnet-057c90cfe7b2e5646"
  vpc_id = "vpc-04f28c9347af48b55"
  tags = {
    project="swarms"
  }
}

module "security" {
  source = "./components/security"
}

module "kp" {
  source = "./components/keypairs"
}

module "lt" {
  instance_type = local.instance_type
  security_group_id = module.security.security_group_id
  source = "./components/launch_template"
}


module "asg" {
  source = "./components/autoscaling_group"
  security_group_id = module.security.security_group_id
  instance_type = local.instance_type
  launch_template_id = module.lt.launch_template_id
}

# module "alb" {
# #  count = 0
#   source = "./components/application_load_balancer"
#   vpc_id = local.vpc_id
# }
# │


output launch_template_id {
  value = module.lt.launch_template_id
}

output security_group_id {
  value = module.security.security_group_id
}
