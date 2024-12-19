variable tags {}
# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }

#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "AWS"
#       identifiers = ["${var.assume_role_arns}"]
#     }
#   }
# }

data "aws_iam_policy_document" "default" {
  statement {
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
    effect    = "Allow"
  }

#  statement {
#    actions   = ["${var.ssm_actions}"]
#    resources = ["${formatlist("arn:aws:ssm:%s:%s:parameter/%s", var.region, var.account_id, var.ssm_parameters)}"]
#    effect    = "Allow"
#  }

  # statement {
  #   actions   = ["kms:Decrypt"]
  #   resources = ["${data.aws_kms_key.default.arn}"]
  #   effect    = "Allow"
  # }
}

resource "aws_iam_policy" "default" {
  name        = "swarms-ssm"
  description = "Allow SSM actions"
  policy      = data.aws_iam_policy_document.default.json
}


resource "aws_iam_role_policy_attachment" "default" {
#  count = local.policy_only
  role       = join("", aws_iam_role.ssm.*.name)
  policy_arn = join("", aws_iam_policy.default.*.arn)
}

resource "aws_iam_role_policy_attachment" "SSM-role-policy-attach" {
  role       = join("", aws_iam_role.ssm.*.name)
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}


####
# resource "aws_iam_role" "default" {
# #  count = local.policy_only

#   name                 = "swarms-ssm"
#   assume_role_policy   = join("", data.aws_iam_policy_document.assume_role.*.json)
#   description          = "IAM Role with permissions to perform actions on SSM resources"
#   max_session_duration = var.max_session_duration
# }
data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "ssm" {
  name = "ssm-swarms-role"
  tags = var.tags

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

resource "aws_iam_instance_profile" "ssm" {
  name = "ssm-swarms-profile"
  role = aws_iam_role.ssm.name
  tags = var.tags
}


output ssm_profile_name {
  value = aws_iam_instance_profile.ssm.name
}

output ssm_profile_arn {
  value = aws_iam_instance_profile.ssm.arn
}
