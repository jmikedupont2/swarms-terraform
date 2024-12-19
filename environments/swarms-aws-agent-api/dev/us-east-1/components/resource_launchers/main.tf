resource "aws_iam_role" "lambda_role" {
  name = "${local.name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda_scaling_policy" {
  name        = "${local.name}-scaling-policy"
  description = "Policy to allow Lambda to manage Auto Scaling"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:SetDesiredCapacity"
      ]
      Resource = "*"
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_scaling_policy.arn
}

resource "aws_lambda_function" "scale_lambda" {
  function_name = "${local.name}-scale-lambda"
  role          = aws_iam_role.lambda_role.arn

  runtime        = "python3.8"
  handler        = "scale_lambda.handler"

  source_code_hash = filebase64sha256("lambda/scale_lambda.zip")
  
  # Environment variables for the Lambda function
  environment = {
    AUTO_SCALING_GROUP_NAME = aws_autoscaling_group.ec2_autoscaling_group.name
  }
}
```

### 4. Lambda Function Code (Python)

You'll need to create a file named `scale_lambda.py` in the `lambda/` directory with content like the following:

```python
import boto3
import os

def handler(event, context):
    asg_name = os.environ['AUTO_SCALING_GROUP_NAME']
    client = boto3.client('autoscaling')

    response = client.describe_auto_scaling_groups(AutoScalingGroupNames=[asg_name])
    desired_capacity = response['AutoScalingGroups'][0]['DesiredCapacity']
    
    # Example scaling logic
    client.set_desired_capacity(
        AutoScalingGroupName=asg_name,
        DesiredCapacity=desired_capacity + 1,  # Increment desired instances
        HonorCooldown=True
    )
