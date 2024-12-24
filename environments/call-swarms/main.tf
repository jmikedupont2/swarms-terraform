# from
# https://github.com/shaikis/terraform-aws-ssm-document.git

locals {
  module_path        = abspath(path.module)
  codebase_root_path = abspath("${path.module}/../..")
}

resource "aws_ssm_document" "deploy" {
  name            = "deploy"
  document_format = "YAML"
  document_type   = "Command"

  content = file("${local.codebase_root_path}/environments/call-swarms/deploy.yaml")
  tags    = { env = "test" }
}

resource "aws_ssm_document" "deploy-docker" {
  name            = "deploy-docker"
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${local.codebase_root_path}/environments/call-swarms/deploy-docker.yaml")
  tags            = { env = "test" }
}


# create a terraform code to deploy this and attach 
# To allow the specified `ssm:SendCommand` operation, you need to create an IAM policy that grants the necessary permissions for the assumed role. The policy should be attached to the role `github`. Here’s a sample IAM policy:

# ```json
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ssm:SendCommand",
#                 "ssm:ListCommands",
#                 "ssm:GetCommandInvocation"
#             ],
#             "Resource": "*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "ec2:DescribeInstances"
#             ],
#             "Resource": "*"
#         }
#     ]
# }
# ```

# ### Steps to implement:

# 1. **Go to the IAM Console** in your AWS Management Console.
# 2. **Locate the Role**: Search for the `github` role.
# 3. **Attach Policy**:
#    - Go to the "Permissions" tab and click "Add inline policy."
#    - Choose "JSON" and paste the policy above into the policy editor.
#    - Review and give the policy a name, then save it.

# ### Additional Notes:
# - Adjust the `Resource` element if you want to restrict access to specific resources rather than all (`*`). For example, you can specify the ARNs of specific EC2 instances or SSM documents.
# - Always follow the principle of least privilege to ensure you only grant the permissions that are necessary.

# To deploy an IAM policy for the `github` role that allows the `ssm:SendCommand` operation, you can use Terraform. Below is a sample Terraform code snippet to create the IAM policy and attach it to the `github` role:

# ```hcl
# provider "aws" {
#   region = "us-east-1"  # Change to your desired region
# }
# resource "aws_iam_policy" "github_ssm_policy" {
#   name        = "GitHubSSMPolicy"
#   description = "Policy to allow SSM commands for GitHub role"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "ssm:SendCommand",
#           "ssm:ListCommands",
#           "ssm:GetCommandInvocation"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "ec2:DescribeInstances"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "attach_github_ssm_policy" {
#   policy_arn = aws_iam_policy.github_ssm_policy.arn
#   role       = "github"  # Ensure this matches your IAM role
# }

# output "policy_arn" {
#   value = aws_iam_policy.github_ssm_policy.arn
# }
# ```

# ### Instructions:


# 1. **Install Terraform** if you haven't already.
# 2. **Configure AWS Credentials**: Ensure your AWS credentials are set up properly (e.g., using `aws configure`).
# 3. **Create a new Terraform file** (e.g., `main.tf`) and paste the above code into it.
# 4. **Initialize Terraform**: Run `terraform init` in your terminal to initialize the working directory.
# 5. **Apply the Terraform configuration**: Run `terraform apply`, and confirm the changes when prompted.

# This code will create a new IAM policy that allows the specified actions and automatically attach it to the existing `github` role. Adjust the policy as needed for your security requirements.
