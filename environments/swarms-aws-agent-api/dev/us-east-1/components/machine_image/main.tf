provider "aws" {
  region = "us-east-1"
}

locals {
  ami = "ami-0e2c8caa4b6378d8c"
  name   = "swarms"
  region = "us-east-1"
  ec2_subnet_id = "subnet-057c90cfe7b2e5646"
  vpc_id = "vpc-04f28c9347af48b55"
  tags = {
    project="swarms"
  }
}

module "security_group_instance" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"
  name        = "${local.name}-ec2"
  description = "Security Group for EC2 Instance"
  vpc_id = local.vpc_id
  ingress_with_cidr_blocks = [
     {
       from_port   = 443
       to_port     = 443
       protocol    = "tcp"
       cidr_blocks = "0.0.0.0/0"
     },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_rules = ["all-all"]
  tags = local.tags
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  associate_public_ip_address = true # for now
  name =  local.name
  ami   = local.ami # data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  vpc_security_group_ids = [module.security_group_instance.security_group_id]

  root_block_device = [
    {
      encrypted   = true
      volume_size = 30
      volume_type           = "gp3"
    }
  ]

  user_data = <<-EOF
#!/bin/bash
export HOME=/root
apt update
apt-get install -y ec2-instance-connect git virtualenv

if [ ! -d "/opt/swarms/" ];
  then
  git clone https://github.com/jmikedupont2/swarms "/opt/swarms/"
fi    
cd "/opt/swarms/" || exit 1 # "we need swarms"
export BRANCH=feature/ec2
git checkout --force  $BRANCH
bash -x /opt/swarms/api/install.sh
              EOF
  tags = local.tags  
  create_spot_instance = true
  subnet_id     = local.ec2_subnet_id
}


output "ec2_data" {
  value = module.ec2
}

output "iam_instance_profile_name" {
  value = module.ec2.iam_instance_profile_id
  description = "IAM Instance Profile Name created for EC2 instance"
}
