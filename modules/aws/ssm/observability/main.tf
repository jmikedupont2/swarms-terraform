# Description: Terraform configuration for SSM observability setup.
# Author: <Your Name>
# Date: 2024-12-22

variable ami_id {}
# Previous provider and variables configuration remains the same
#provider "aws" {
#  region = var.aws_region
#}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "patch_schedule" {
  description = "Cron expression for patch schedule"
  type        = string
  default     = "cron(0 0 ? * SUN *)"  # Run at midnight every Sunday
}

# Update EC2 role to include SSM permissions
resource "aws_iam_role" "ec2_monitoring_role" {
  name = "ec2-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Add SSM policy attachments
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  role       = aws_iam_role.ec2_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Previous instance profile configuration remains the same
resource "aws_iam_instance_profile" "monitoring_profile" {
  name = "ec2-monitoring-profile"
  role = aws_iam_role.ec2_monitoring_role.name
}

# SSM Patch Baseline
resource "aws_ssm_patch_baseline" "os_patches" {
  name             = "ec2-patch-baseline"
  operating_system = "AMAZON_LINUX_2"
  
  approval_rule {
    approve_after_days = 7
    compliance_level   = "HIGH"

    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security", "Bugfix", "Recommended"]
      #valid values are: Security, Bugfix, Enhancement, Recommended, Newpackage
    }

    patch_filter {
      key    = "SEVERITY"
      values = ["Critical", "Important"]
    }
  }

  tags = {
    Environment = "Production"
  }
}

# SSM Patch Group
resource "aws_ssm_patch_group" "patch_group" {
  baseline_id = aws_ssm_patch_baseline.os_patches.id
  patch_group = "production-servers"
}

# SSM Maintenance Window
resource "aws_ssm_maintenance_window" "patch_window"{
  cutoff = 1
  name                       = "production-patch-window"
  schedule                   = var.patch_schedule
  duration                   = 4 #"PT4H"    # 4 hours
  allow_unassociated_targets = false
}

# Maintenance Window Target
resource "aws_ssm_maintenance_window_target" "patch_target" {
  resource_type = "INSTANCE"
  window_id = aws_ssm_maintenance_window.patch_window.id
  name      = "patch-production-servers"
  
  targets {
    key    = "tag:PatchGroup"
    values = ["production-servers"]
  }
}

# Maintenance Window Task
resource "aws_ssm_maintenance_window_task" "patch_task" {
  window_id        = aws_ssm_maintenance_window.patch_window.id
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  service_role_arn = aws_iam_role.maintenance_window_role.arn
  priority         = 1
  max_concurrency  = "50%"
  max_errors       = "25%"

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patch_target.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      parameter {
        name   = "RebootOption"
        values = ["RebootIfNeeded"]
      }
    }
  }
}

# Maintenance Window Role
resource "aws_iam_role" "maintenance_window_role" {
  name = "ssm-maintenance-window-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
      }
    ]
  })
}

# Attach required policies for Maintenance Window Role
resource "aws_iam_role_policy_attachment" "maintenance_window_policy" {
  role       = aws_iam_role.maintenance_window_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

# # Update EC2 instance configuration with patch group tag
# resource "aws_instance" "monitored_instance" {
#   ami           = var.ami_id
#   instance_type = var.instance_type
  
#   iam_instance_profile = aws_iam_instance_profile.monitoring_profile.name
#   monitoring           = true

#   user_data = <<-EOF
#               #!/bin/bash
#               yum update -y
#               yum install -y amazon-cloudwatch-agent
#               amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:${aws_ssm_parameter.cw_agent_config.name}
#               systemctl start amazon-cloudwatch-agent
#               systemctl enable amazon-cloudwatch-agent
#               EOF

#   tags = {
#     Name       = "monitored-instance"
#     PatchGroup = "production-servers"
#   }
# }

# Add CloudWatch Event Rule for Patch Compliance Monitoring
resource "aws_cloudwatch_event_rule" "patch_compliance" {
  name        = "patch-compliance-monitoring"
  description = "Monitor patch compliance state changes"

  event_pattern = jsonencode({
    source      = ["aws.ssm"]
    detail-type = ["Patch Compliance State Change"]
  })
}

resource "aws_cloudwatch_event_target" "patch_compliance_sns" {
  rule      = aws_cloudwatch_event_rule.patch_compliance.name
  target_id = "PatchComplianceNotification"
  arn       = aws_sns_topic.patch_notifications.arn
}

# SNS Topic for Patch Notifications
resource "aws_sns_topic" "patch_notifications" {
  name = "patch-compliance-notifications"
}


# SSM State Manager association for CloudWatch agent updates
resource "aws_ssm_association" "cloudwatch_agent_update" {
  name = "AWS-ConfigureAWSPackage"

  targets {
    key    = "tag:Monitoring"
    values = ["enabled"]
  }

  parameters = {
    action = "Install"
    name   = "AmazonCloudWatchAgent"
  }
}

locals {
  normal_config = {
    "agent": {
        "metrics_collection_interval": 60
    },
    "metrics": {
        "namespace": "CWAgent",
        "append_dimensions": {
          "InstanceId": "$${aws:InstanceId}"
        },
        "metrics_collected": {
            "mem": {
                "measurement": [
                    "used_percent",
                    "used",
                    "total",
                    "inactive",
                    "free",
                    "cached",
                    "buffered",
                    "available_percent",
                    "available",
                    "active"
                ]
            },
            "cpu": {
                "measurement": [
                    "usage_active",
                    "time_guest_nice",
                    "time_idle",
                    "time_irq",
                    "time_iowait",
                    "time_guest",
                    "time_active",
                    "time_softirq",
                    "time_nice",
                    "time_system",
                    "time_user",
                    "time_steal",
                    "usage_guest",
                    "usage_guest_nice",
                    "usage_idle",
                    "usage_iowait",
                    "usage_irq",
                    "usage_nice",
                    "usage_softirq",
                    "usage_steal"
                ]
            },
            "disk": {
                "measurement": [
                    "used_percent",
                    "free",
                    "inodes_free",
                    "inodes_total",
                    "inodes_used",
                    "total",
                    "used"
                ]
            },
            "diskio": {
                "measurement": [
                    "read_bytes",
                    "write_bytes",
                    "iops_in_progress",
                    "io_time",
                    "reads",
                    "writes",
                    "read_time",
                    "write_time"
                ]
            },
            "net": {
                "measurement": [
                    "bytes_sent",
                    "bytes_recv",
                    "drop_in",
                    "drop_out",
                    "err_in",
                    "err_out",
                    "packets_sent",
                    "packets_recv"
                ]
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_close",
                    "tcp_close_wait",
                    "tcp_closing",
                    "tcp_fin_wait1",
                    "tcp_last_ack",
                    "tcp_listen",
                    "tcp_fin_wait2",
                    "tcp_none",
                    "tcp_syn_recv",
                    "tcp_time_wait",
                    "tcp_syn_sent",
                    "udp_socket"
                ]
            },
            "processes": {
                "measurement": [
                    "running",
                    "wait",
                    "zombies",
                    "total_threads",
                    "total",
                    "paging",
                    "sleeping",
                    "stopped",
                    "dead",
                    "blocked",
                    "idle"
                ]
            },
            "swap": {
                "measurement": [
                    "used_percent",
                    "free",
                    "used"
                ]
            }
        }
    },
    "traces": {
        "traces_collected": {
            "xray": {},
            "otlp": {},
            "application_signals": {}
        }
    }
  }
  
  detailed_config = {
    agent = {
      metrics_collection_interval = 60
      run_as_user               = "root"
    }
    metrics = {
      namespace = "CustomEC2Metrics"
      metrics_collected = {
        cpu = {
          resources = ["*"]
          measurement = [
            "cpu_usage_idle",
            "cpu_usage_user",
            "cpu_usage_system",
            "cpu_usage_iowait"
          ]
          totalcpu = true
          metrics_collection_interval = 60
        }
        mem = {
          measurement = [
            "mem_used_percent",
            "mem_total",
            "mem_used",
            "mem_cached",
            "mem_buffered"
          ]
          metrics_collection_interval = 60
        }
        disk = {
          resources = ["/"]
          measurement = [
            "disk_used_percent",
            "disk_free",
            "disk_total",
            "disk_inodes_free",
            "disk_inodes_used"
          ]
          metrics_collection_interval = 60
        }
        netstat = {
          metrics_collection_interval = 60
          measurement = [
            "tcp_established",
            "tcp_time_wait"
          ]
        }
      }
    }
    logs = {
      log_stream_name="logs"
      force_flush_interval=60
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path = "/var/log/messages"
              log_group_name = "/ec2/system"
              log_stream_name = "{instance_id}"
              timezone = "UTC"
            },
	    
	   # nginx
            {
              file_path = "/var/log/nginx/swarms/access.log"
              log_group_name = "/swarms/ngnix_access"
              log_stream_name = "{instance_id}"
              timezone = "UTC"
            },
            {
              file_path = "/var/log/nginx/swarms/error.log"
              log_group_name = "/swarms/nginx_error"
              log_stream_name = "{instance_id}"
              timezone = "UTC"
            },

            {
              file_path = "/var/log/cloud-init-output.log"
              log_group_name = "/ec2/init"
              log_stream_name = "{instance_id}"
              timezone = "UTC"
            },
            {
              file_path = "/var/log/swarms_systemd.log"
              log_group_name = "/swarms/systemd"
              log_stream_name = "{instance_id}"
              timezone = "UTC"
            },
            {
              file_path = "/var/log/secure"
              log_group_name = "/ec2/secure"
              log_stream_name = "{instance_id}"
              timezone = "UTC"
            }
          ]
        }
      }
    }
  }
}
# Updated CloudWatch Agent configuration in SSM Parameter Store
resource "aws_ssm_parameter" "cw_agent_config" {
  name        = "/cloudwatch-agent/config"
  description = "CloudWatch agent configuration"
  type        = "SecureString"
  value       = jsonencode(local.normal_config)
}

# SSM command to update CloudWatch configuration on running instances
resource "aws_ssm_association" "update_cloudwatch_config" {
  name = "AWS-RunShellScript"

  targets {
    key    = "tag:Monitoring"
    values = ["enabled"]
  }

  parameters = {
    commands = "amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:${aws_ssm_parameter.cw_agent_config.name}\n      systemctl restart amazon-cloudwatch-agent"
    
  }
}

resource "aws_cloudwatch_log_group" "log_groups" {
  for_each = toset([
    "/swarms/ngnix_access",
    "/swarms/nginx_error",
    "/swarms/systemd", "/ec2/init"  ])
  name     = each.key
  retention_in_days = 30
  kms_key_id = "arn:aws:kms:us-east-2:916723593639:key/cc8e1ee7-a05b-4642-bd81-ba5548635590"
}

# CloudWatch Log Groups for collected logs
resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/ec2/system"
  retention_in_days = 30
  kms_key_id = "arn:aws:kms:us-east-2:916723593639:key/cc8e1ee7-a05b-4642-bd81-ba5548635590"
}

resource "aws_cloudwatch_log_group" "secure_logs" {
  name              = "/ec2/secure"
  retention_in_days = 30
  kms_key_id = "arn:aws:kms:us-east-2:916723593639:key/cc8e1ee7-a05b-4642-bd81-ba5548635590"
}

# SSM Document for CloudWatch agent troubleshooting
resource "aws_ssm_document" "cloudwatch_agent_troubleshoot" {
  name            = "TroubleshootCloudWatchAgent"
  document_type   = "Command"
  document_format = "YAML"

  content = <<DOC
schemaVersion: '2.2'
description: 'Troubleshoot CloudWatch Agent'
parameters: {}
mainSteps:
  - action: aws:runShellScript
    name: CheckCloudWatchAgent
    inputs:
      runCommand:
        - systemctl status amazon-cloudwatch-agent
        - cat /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
        - ps aux | grep amazon-cloudwatch-agent
        - amazon-cloudwatch-agent-ctl -a status
DOC
}

# Output the troubleshooting command
output "troubleshoot_command" {
  value = "aws ssm start-automation-execution --document-name ${aws_ssm_document.cloudwatch_agent_troubleshoot.name} --target Key=tag:Monitoring,Values=enabled"
}

# Updated CloudWatch Agent configuration in SSM Parameter Store
resource "aws_ssm_parameter" "cw_agent_config_details" {
  name        = "/cloudwatch-agent/config/details"
  description = "CloudWatch agent configuration with details"
  type        = "SecureString"
  value       = jsonencode(local.detailed_config)
}
