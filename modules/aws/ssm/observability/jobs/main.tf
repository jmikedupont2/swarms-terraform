# S3 Bucket for SSM logs and outputs
resource "aws_s3_bucket" "ssm_logs" {
  bucket = "ssm-operation-logs-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "ssm_logs" {
  bucket = aws_s3_bucket.ssm_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ssm_logs" {
  bucket = aws_s3_bucket.ssm_logs.id

  rule {
    id     = "cleanup_old_logs"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 90
    }
  }
}

# SSM Session logging to S3
resource "aws_s3_bucket_policy" "ssm_logs" {
  bucket = aws_s3_bucket.ssm_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SSMBucketPermission"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.ssm_logs.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudWatch Log Group for SSM
resource "aws_cloudwatch_log_group" "ssm_logs" {
  name              = "/aws/ssm/operations"
  retention_in_days = 30
}

# X-Ray tracing configuration
resource "aws_xray_sampling_rule" "ssm_tracing" {
  rule_name      = "SSMOperations"
  priority       = 1000
  reservoir_size = 1
  fixed_rate     = 0.05
  host           = "*"
  http_method    = "*"
  url_path       = "*"
  service_name   = "*"
  service_type   = "*"
  version        = 1
}

# IAM role updates for X-Ray and enhanced logging
resource "aws_iam_role_policy_attachment" "xray_policy" {
  role       = aws_iam_role.maintenance_window_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# Custom policy for S3 and CloudWatch access
resource "aws_iam_role_policy" "ssm_logging" {
  name = "ssm-logging-policy"
  role = aws_iam_role.maintenance_window_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.ssm_logs.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.ssm_logs.arn}:*"
      }
    ]
  })
}

# Updated SSM Document for Python script execution with X-Ray tracing
resource "aws_ssm_document" "python_with_xray" {
  name            = "RunPythonWithXRay"
  document_type   = "Command"
  document_format = "YAML"

  content = <<DOC
schemaVersion: '2.2'
description: 'Execute Python script with X-Ray tracing'
parameters:
  ScriptContent:
    type: String
    description: 'Python script content'
mainSteps:
  - action: aws:runShellScript
    name: InstallDependencies
    inputs:
      runCommand:
        - yum install -y python3-pip
        - pip3 install aws-xray-sdk boto3
  - action: aws:runShellScript
    name: ConfigureXRay
    inputs:
      runCommand:
        - |
          cat > /tmp/xray-daemon.json << 'EOF'
          {
            "Version": 1,
            "RecordingName": "SSMOperation",
            "RecordingType": "ServiceType",
            "SamplingRule": {
              "FixedRate": 1,
              "ReservoirSize": 5
            }
          }
          EOF
        - curl https://s3.us-east-2.amazonaws.com/aws-xray-assets.us-east-2/xray-daemon/aws-xray-daemon-linux-3.x.zip -o /tmp/xray-daemon.zip
        - unzip /tmp/xray-daemon.zip -d /opt/xray
        - /opt/xray/xray-daemon -c /tmp/xray-daemon.json &
  - action: aws:runShellScript
    name: ExecuteScript
    inputs:
      runCommand:
        - |
          cat > /tmp/wrapper.py << 'EOF'
          import boto3
          from aws_xray_sdk.core import xray_recorder
          from aws_xray_sdk.core import patch_all
          import os
          import sys
          import json
          
          # Initialize X-Ray
          xray_recorder.configure(
              context_missing='LOG_ERROR',
              service='SSMPythonOperation'
          )
          patch_all()
          
          # Start X-Ray segment
          segment = xray_recorder.begin_segment('SSMPythonScript')
          
          try:
              # Execute the actual script
              with open('/tmp/script.py', 'r') as f:
                  exec(f.read())
          except Exception as e:
              segment.put_annotation('error', str(e))
              raise
          finally:
              xray_recorder.end_segment()
          EOF
        - echo "{{ ScriptContent }}" > /tmp/script.py
        - python3 /tmp/wrapper.py
DOC
}

# CloudWatch Dashboard for SSM Operations
resource "aws_cloudwatch_dashboard" "ssm_operations" {
  dashboard_name = "SSMOperations"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/SSM", "CommandSuccess", "DocumentName", "RunPythonWithXRay"],
            ["AWS/SSM", "CommandFailed", "DocumentName", "RunPythonWithXRay"]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "SSM Command Execution Status"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          query        = "fields @timestamp, @message | sort @timestamp desc | limit 20"
          region       = var.aws_region
          title        = "Recent SSM Operation Logs"
          view         = "table"
          logGroupName = aws_cloudwatch_log_group.ssm_logs.name
        }
      }
    ]
  })
}

# Get current account ID
data "aws_caller_identity" "current" {}

# CloudWatch Metric Alarm for Failed Commands
resource "aws_cloudwatch_metric_alarm" "ssm_failures" {
  alarm_name          = "ssm-command-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CommandFailed"
  namespace           = "AWS/SSM"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors failed SSM commands"

  dimensions = {
    DocumentName = aws_ssm_document.python_with_xray.name
  }
}