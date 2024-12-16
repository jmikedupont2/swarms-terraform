variable target_group_arn{}
#variable security_group_id {}
variable name {}
variable instance_type {
 # default = "t3.micro"
}

variable launch_template_id {

}
variable  image_id {
  default = "ami-0e2c8caa4b6378d8c"
}
variable  vpc_id {
  default = "vpc-04f28c9347af48b55"
}
#provider "aws" {
#  region = "us-east-1"
#}

locals {
  ami = "ami-0e2c8caa4b6378d8c"
 # name   = "swarms"
  region = "us-east-1"
  ec2_subnet_id = "subnet-057c90cfe7b2e5646"

  #iam_instance_profile_name = "swarms-20241213150629570500000003"
  iam_instance_profile_arn = aws_iam_instance_profile.ssm.arn
  tags = {
    project="swarms"
  }

  instance_type = var.instance_type
}

resource "aws_iam_instance_profile" "ssm" {
  name = "ssm-${var.name}"
  role = aws_iam_role.ssm.name
  tags = local.tags
}
resource "aws_iam_role" "ssm" {
  name = "ssm-${var.name}"
  tags = local.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "8.0.0"
  name = var.name

  health_check_type         = "EC2"
  desired_capacity     = 1
  max_size             = 5
  min_size             = 1

  create_launch_template = false
  update_default_version      = true
  
  launch_template_id   = var.launch_template_id
  launch_template_version   = "$Latest"

  vpc_zone_identifier = [local.ec2_subnet_id]

  instance_market_options = {
    market_type = "spot"
  }
  network_interfaces = [{
    associate_public_ip_address=true
    device_index                = 0
    delete_on_termination       = true
    description                 = "interface1"
#    security_groups       = [var.security_group_id]
  }
  ]
  instance_type = var.instance_type
  image_id = var.image_id

  
  create_iam_instance_profile = true
  iam_role_name               = "ssm-${var.name}"
  iam_role_path               = "/ec2/"
  iam_role_description        = "SSM IAM role for swarms"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }

  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  #    target_group_arn = 
  traffic_source_attachments = {
    ex-alb = {
      traffic_source_identifier = var.target_group_arn
      traffic_source_type       = "elbv2" # default
    }
  }

}
