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

output api {
  value = module.swarms_api
}
