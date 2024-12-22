variable tags {}

data "aws_iam_policy_document" "default" {
  statement {
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
    effect    = "Allow"
  }

   statement {
     actions = ["kms:Decrypt"]
     resources = [ "arn:aws:kms:us-east-2:916723593639:key/cc8e1ee7-a05b-4642-bd81-ba5548635590" ]
     effect    = "Allow"
   }

   statement {
     actions = [
       "logs:DescribeLogGroups",
       "logs:DescribeLogStreams",
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents",
       "logs:PutLogEventsBatch",
       "cloudwatch:PutMetricData",
       "ec2:DescribeTags",
     ]
     resources = [ "*" ]
     effect    = "Allow"
   }

  statement {
    effect = "Allow"
    resources = [  "arn:aws:s3:::swarms-session-logs*"  ]
    actions = [
      "s3:GetEncryptionConfiguration"
    ]
  }
    
  statement {
    effect = "Allow"
         resources = [ "*" ]
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
  }

  # statement {
  #   sid    = "Allow CloudWatch access"
  #   effect = "Allow"
  #   principals {
  #     type        = "Service"
  #     identifiers = ["logs.us-east-2.amazonaws.com"]
  #   }
  #   actions = [
  #     "kms:Encrypt*",
  #     "kms:Decrypt*",
  #     "kms:ReEncrypt*",
  #     "kms:GenerateDataKey*",
  #     "kms:Describe*"
  #   ]
  #   condition {
  #     test     = "ArnLike"
  #     values   = ["arn:aws:logs:region:${data.aws_caller_identity.current.account_id}:*"]
  #     variable = "kms:EncryptionContext:aws:logs:arn"
  #   }
  # }

  #arn:aws:logs:us-east-2:916723593639:log-group::log-stream
  
#  statement {
#    actions   = ["${var.ssm_actions}"]
#    resources = ["${formatlist("arn:aws:ssm:%s:%s:parameter/%s", var.region, var.account_id, var.ssm_parameters)}"]
#    effect    = "Allow"
#  }

}

resource "aws_iam_policy" "default" {
  name        = "swarms-ssm"
  description = "Allow SSM actions"
  policy      = data.aws_iam_policy_document.default.json
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedEC2InstanceDefaultPolicy" {
  role       = join("", aws_iam_role.ssm.*.name)
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
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
