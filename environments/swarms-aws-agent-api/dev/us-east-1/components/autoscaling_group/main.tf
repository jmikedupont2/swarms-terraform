variable aws_iam_instance_profile_ssm_arn {}
#variable target_group_arn{}
variable name {}
variable instance_type {}
variable launch_template_id {}
variable image_id {}
variable vpc_id {}
variable tags {}
variable ec2_subnet_id {}

locals {
  iam_instance_profile_arn = var.aws_iam_instance_profile_ssm_arn
  instance_type = var.instance_type
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

  vpc_zone_identifier = [var.ec2_subnet_id]

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
  # traffic_source_attachments = {
  #   ex-alb = {
  #     traffic_source_identifier = var.target_group_arn
  #     traffic_source_type       = "elbv2" # default
  #   }
  # }

}
