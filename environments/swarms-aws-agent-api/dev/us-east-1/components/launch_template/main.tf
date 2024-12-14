variable security_group_id {}
variable  vpc_id {
  default = "vpc-04f28c9347af48b55"
}

variable key_name {
  default = "mdupont-deployer-key"
}
variable instance_type {
 # default = "t3.micro"
}

provider "aws" {
  region = "us-east-1"
}

locals {
  ami = "ami-0e2c8caa4b6378d8c"
  name   = "swarms"
  region = "us-east-1"
  ec2_subnet_id = "subnet-057c90cfe7b2e5646"
  vpc_id = "vpc-04f28c9347af48b55"
  iam_instance_profile_name = "swarms-20241213150629570500000003"
  tags = {
    project="swarms"
  }
}



resource "aws_launch_template" "ec2_launch_template" {
  name_prefix           = "${local.name}-launch-template-"
  image_id              = local.ami
  #  instance_type        = "t3.large"
  key_name = var.key_name
  instance_type        = var.instance_type#"t3.micro"
#  vpc_security_group_ids          = [var.security_group_id]
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination = true
    security_groups          = [var.security_group_id]
  }
  
  iam_instance_profile {
    name = local.iam_instance_profile_name #aws_iam_instance_profile.ec2_instance_profile.name
  }

#  key_name = "your-key-pair" # Replace with your key pair name

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 30
      volume_type = "gp3"
      encrypted   = true
    }
  }

  user_data = base64encode(<<-EOF
  #!/bin/bash
  export HOME=/root
  apt update
  apt-get install -y ec2-instance-connect git virtualenv
  snap install amazon-ssm-agent --classic || echo oops1
  snap start amazon-ssm-agent || echo oops2
  apt-get install -y --no-install-recommends ca-certificates=20230311 curl=7.88.1-10+deb12u7 |  echo oops
  curl -O "https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/$(dpkg --print-architecture)/latest/amazon-cloudwatch-agent.deb"
  dpkg -i -E amazon-cloudwatch-agent.deb
 
  if [ ! -d "/opt/swarms/" ]; then
    git clone https://github.com/jmikedupont2/swarms "/opt/swarms/"
  fi
  cd "/opt/swarms/" || exit 1
  export BRANCH=feature/ec2
  git stash
  git checkout --force $BRANCH
  bash -x /opt/swarms/api/install.sh
  EOF
    )
  tags = local.tags  
}


output "lt" {
  value = resource.aws_launch_template.ec2_launch_template
}
output "launch_template_id" {
  value = resource.aws_launch_template.ec2_launch_template.id
}
