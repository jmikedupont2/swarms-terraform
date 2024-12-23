variable region {}
variable key_name {
  default = "mdupont-deployer-key" # FIXME: move to settings
}
locals {
  #  instance_type = "t3.large"
  #  instance_type = "t3.medium"
  ami_name = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
  name   = "swarms"
  domain = var.domain
  tags = {
    project="swarms"
  }
  dev_tags = {
    sandbox="kye"
  }
}
variable domain {}
variable aws_account_id {}
variable ami_id {}
variable tags {}
variable name {}


locals {
  ami_id  = var.ami_id
  new_ami_id = "ami-08093b6770af41b14" # environments/swarms-aws-agent-api/dev/us-east-1/components/machine_image/Readme.md
}

# SLOW
module "vpc" {
  source = "./components/vpc"
}

locals {
  ec2_public_subnet_id_1 = module.vpc.ec2_public_subnet_id_1
  ec2_public_subnet_id_2 = module.vpc.ec2_public_subnet_id_2
  vpc_id = module.vpc.vpc_id
}

module "security" {
  source = "./components/security"
  vpc_id = local.vpc_id
  tags = local.tags
  name = local.name
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


module "roles" {
  source = "./components/roles"
  tags = local.tags
}

# module "lt_dynamic" {
#   vpc_id = local.vpc_id
#   branch =  "feature/ec2"
#   for_each = toset(var.instance_types)
#   instance_type       = each.key
#   name       = "swarms-size-${each.key}"
#   security_group_id = module.security.internal_security_group_id
#   ami_id = var.ami_id
#   tags= local.tags
#   source = "./components/launch_template"
#   iam_instance_profile_name = module.roles.ssm_profile_name
#   #aws_iam_instance_profile.ssm.name
#   install_script = "/opt/swarms/api/install.sh"
# }

module "lt_dynamic_ami_prod" {
  vpc_id = local.vpc_id
  for_each = toset(var.instance_types)
  instance_type       = each.key
  name       = "swarms-ami-${each.key}"
  security_group_id = module.security.internal_security_group_id
  ami_id = local.new_ami_id
  key_name = var.key_name
  tags= merge(local.tags, {
    environment = "production"
  })
  source = "./components/launch_template"
  iam_instance_profile_name = module.roles.ssm_profile_name
  install_script = "/opt/swarms/api/just_run.sh"
  ssm_parameter_name_cw_agent_config= "arn:aws:ssm:${var.region}:${var.aws_account_id}:parameter/cloudwatch-agent/config"
  branch =  "feature/ec2"
}

module "lt_dynamic_ami_test" {
  branch =  "feature/cloudwatch"
  vpc_id = local.vpc_id
  for_each = toset(var.instance_types)
  instance_type       = each.key
  name       = "swarms-ami-${each.key}"
  security_group_id = module.security.internal_security_group_id
  ami_id = local.new_ami_id
  tags= merge(local.tags, {
    environment = "test"
  })
  source = "./components/launch_template"
  key_name = var.key_name #"mdupont-deployer-key"
  ssm_parameter_name_cw_agent_config= "arn:aws:ssm:${var.region}:${var.aws_account_id}:parameter/cloudwatch-agent/config/details"
  iam_instance_profile_name = module.roles.ssm_profile_name
  install_script = "/opt/swarms/api/just_run.sh"
}


module "lt_dynamic_ami_docker" {
  branch =  "feature/squash2-docker"
  vpc_id = local.vpc_id
  for_each = toset(var.instance_types)
  instance_type = each.key
  name   = "swarms-docker-${each.key}"
  security_group_id = module.security.internal_security_group_id
  ami_id = local.new_ami_id
  tags= merge(local.tags, {
    environment = "test"
  })
  source = "./components/launch_template_docker"
  key_name = var.key_name #"mdupont-deployer-key"
  ssm_parameter_name_cw_agent_config= "arn:aws:ssm:${var.region}:${var.aws_account_id}:parameter/cloudwatch-agent/config/details"
  iam_instance_profile_name = module.roles.ssm_profile_name
  install_script = "/opt/swarms/api/rundocker.sh"
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
output alb {
  value = module.alb
}


# this is the slow one, use the ami
# module "asg_dynamic" {
#   tags = local.tags
#   vpc_id = local.vpc_id
#   image_id = local.ami_id
#   ec2_subnet_id = module.vpc.ec2_public_subnet_id_1
#   for_each = toset(var.instance_types)
#   aws_iam_instance_profile_ssm_arn = module.roles.ssm_profile_arn
#   #iam_instance_profile_name = module.roles.ssm_profile_name
#   source              = "./components/autoscaling_group"
# #  security_group_id   = module.security.internal_security_group_id
#   instance_type       = each.key
#   name       = "swarms-size-${each.key}"
#   launch_template_id   = module.lt_dynamic[each.key].launch_template_id
#   target_group_arn = module.alb.alb_target_group_arn
# }

module "asg_dynamic_new_ami" {
  # built with packer
  #count =0
  tags = local.tags
  vpc_id = local.vpc_id
  image_id = local.new_ami_id
  ec2_subnet_id = module.vpc.ec2_public_subnet_id_1
  for_each = toset(var.instance_types)
  aws_iam_instance_profile_ssm_arn = module.roles.ssm_profile_arn
  source              = "./components/autoscaling_group"
#  security_group_id   = module.security.internal_security_group_id
  instance_type       = each.key
  name       = "swarms-ami-${each.key}"
  launch_template_id   = module.lt_dynamic_ami_prod[each.key].launch_template_id
  target_group_arn = module.alb.alb_target_group_arn
}

module "asg_dynamic_new_ami_test" {
  # built with packer
  #count =0
  tags = merge(local.tags, local.dev_tags)
  vpc_id = local.vpc_id
  image_id = local.new_ami_id
  ec2_subnet_id = module.vpc.ec2_public_subnet_id_1
  for_each = toset(var.instance_types)
  aws_iam_instance_profile_ssm_arn = module.roles.ssm_profile_arn
  source              = "./components/autoscaling_group"
#  security_group_id   = module.security.internal_security_group_id
  instance_type       = each.key
  name       = "test-swarms-ami-${each.key}"
  launch_template_id   = module.lt_dynamic_ami_test[each.key].launch_template_id
  target_group_arn = module.alb.test_alb_target_group_arn
}

output security_group_id {
  value = module.security.security_group_id
}

output vpc {
  value = module.vpc
}


output user_data_new {
  value = module.lt_dynamic_ami_test["t3.medium"].user_data
}
