locals {
  #ami_name = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
  ami_name  = "ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-minimal-*"
  dns = "api.swarms.ai"
  account = "916723593639"
  region  = "us-east-2"
}

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
 data "aws_ami" "ami" {
   most_recent      = true
   name_regex       = "^${local.ami_name}"
 }

module "swarms_api" {
  source = "../../environments/swarms-aws-agent-api/dev/us-east-1"
  domain = local.dns
  ami_id = data.aws_ami.ami.id
  #"ami-0ad5d6c7069ce56ac"
  #ami_id = "ami-0ad5d6c7069ce56ac"

  name = "swarms"
  tags = {project="swarms"}
  
}

module "swarmdeploy" {
  source = "../../environments/swarms-deploy/dev/us-east-1"
  domain = local.dns
  ami_id = data.aws_ami.ami.id
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
