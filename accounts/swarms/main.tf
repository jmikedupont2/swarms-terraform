locals {
  #ami_name = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
  ami_name  = "ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-minimal-*"
  dns = "api.swarms.ai"
  #dns = "api.arianakrasniqi.com"
  account = "916723593639"
  region  = "us-east-2"
}


variable "owner" {
  description = "GitHub owner used to configure the provider"
  default        = "jmikedupont2"
}

variable "github_token" {
  description = "GitHub access token used to configure the provider"
  type        = string
}

provider "github" {
  owner = var.owner
  token = var.github_token
}

#resource aws_route53_zone test{
#  name = local.dns
#}

provider aws {
  region = "us-east-2"
  profile = "swarms"
}
output dns {
  value = local.dns
}

output profile {
  value = "swarms"
}

output account {
  value = "916723593639"
}

output region {
  value = "us-east-2"
}

#SLOW
# data "aws_ami" "ami" {
#   most_recent      = true
#   name_regex       = "^${local.ami_name}"
# }
locals {
ami_id = "ami-0325b9a2dfb474b2d"
}

module "swarms_api" {
  source = "../../environments/swarms-aws-agent-api/dev/us-east-1"
  domain = local.dns
  #ami_id = data.aws_ami.ami.id
  ami_id = local.ami_id
  

  name = "swarms"
  tags = {project="swarms"}
  
}

module "swarmdeploy" {
  source = "../../environments/swarms-deploy/dev/us-east-1"
  domain = local.dns
  #ami_id = data.aws_ami.ami.id
  ami_id = local.ami_id
  name = "swarmdeploy"
  tags = {project="swarmdeploy"}  
  vpc_id = "vpc-0b4cedd083227068d"
  subnet_id = "subnet-04b3bdd4b0dc877f0"
  ssm_profile_arn= "arn:aws:iam::916723593639:instance-profile/ssm-swarms-profile"
  ssm_profile_name = "ssm-swarms-profile"
}

output api {
  value = module.swarms_api
}



# setup the github tokens
module github {
  source = "./github"
  aws_account_id = local.account
  aws_region  = local.region
#  github_token = var.github_token
  repos = toset([
    "terraform-aws-oidc-github",
    "swarms",
    "swarms-terraform"
  ])
}


# now create the ssm document
module call_swarms {
  source = "../../environments/call-swarms"

}
