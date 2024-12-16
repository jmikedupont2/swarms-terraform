locals {
  #  instance_type = "t3.large"
  #  instance_type = "t3.medium"
  ami = "ami-0e2c8caa4b6378d8c"
  name   = "swarms"
  region = "us-east-1"
  domain = "api.introspector.meme"
  ec2_public_subnet_id_1 = "subnet-057c90cfe7b2e5646" # swarms-public-us-east-1a
  ec2_public_subnet_id_2 = "subnet-05d8aef1f71b5fe22" # b
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

# module "lt" {
#   instance_type = local.instance_type
#   security_group_id = module.security.security_group_id
#   source = "./components/launch_template"
# }

# module "asg" {
#   source = "./components/autoscaling_group"
#   name="swarms"
#   security_group_id = module.security.security_group_id
#   instance_type = local.instance_type
#   launch_template_id = module.lt.launch_template_id
# }

variable "instance_types" {
  type    = list(string)
  default = [
   # "t4g.nano", "t3a.nano", "t3.nano", "t2.nano",
   # "t4g.micro", "t3a.micro", "t3.micro", "t2.micro", "t1.micro",
    #"t4g.small", "t3a.small",
    #"t3.small",
    #"t2.small", not working
    #    "t2.medium" #
    "t3.medium"
  ]
}

module "lt_dynamic" {
  for_each = toset(var.instance_types)
  instance_type       = each.key
  name       = "swarms-size-${each.key}"
  security_group_id = module.security.internal_security_group_id
  source = "./components/launch_template"
}

module "alb" { 
  source = "./components/application_load_balancer"
  domain_name = local.domain
  security_group_id   = module.security.security_group_id # allowed to talk to internal
  public_subnets = [
    local.ec2_public_subnet_id_1,
    local.ec2_public_subnet_id_2 ] 
  vpc_id = local.vpc_id
  name = local.name
}

module "asg_dynamic" {
  for_each = toset(var.instance_types)
  source              = "./components/autoscaling_group"
#  security_group_id   = module.security.internal_security_group_id
  instance_type       = each.key
  name       = "swarms-size-${each.key}"
  launch_template_id   = module.lt_dynamic[each.key].launch_template_id
  target_group_arn = module.alb.alb_target_group_arn
}

# module "alb" {
# #  count = 0
#   source = "./components/application_load_balancer"
#   vpc_id = local.vpc_id
# }
# │


#output launch_template_id {
#  value = module.lt.launch_template_id
#}

output security_group_id {
  value = module.security.security_group_id
}

output alb {
  value = module.alb
}
