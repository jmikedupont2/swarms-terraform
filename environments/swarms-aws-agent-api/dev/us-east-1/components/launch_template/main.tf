variable install_script {}
variable iam_instance_profile_name {}
variable security_group_id {}
variable name {}
variable  vpc_id {}
variable  ami_id {}
variable  tags {}
variable key_name {
  default = "mdupont-deployer-key"
}

# dont use this 
variable instance_type {}

locals {
  tags = {
    project="swarms"
    instance_type = var.instance_type
    name = var.name
  }
}
resource "aws_launch_template" "ec2_launch_template" {
  name_prefix           = "${var.name}-launch-template-"
  image_id              = var.ami_id
  key_name = var.key_name
  instance_type        = var.instance_type
  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination = true
    security_groups          = [var.security_group_id]
  }
 
  iam_instance_profile {
    #   iam_instance_profile_arn = aws_iam_instance_profile.ssm.arn
    name = var.iam_instance_profile_name #aws_iam_instance_profile.ec2_instance_profile.name
  }
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
  git pull # get the latest version
  bash -x ${var.install_script}
  EOF
    )
  tags = var.tags  
}


output "lt" {
  value = resource.aws_launch_template.ec2_launch_template
}
output "launch_template_id" {
  value = resource.aws_launch_template.ec2_launch_template.id
}
