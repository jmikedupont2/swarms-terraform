#!/bin/bash
# lets make this bash script into a terraform template 
#aws_ssm_parameter_cw_agent_config_name=${aws_ssm_parameter.cw_agent_config.name}
# Update package lists
apt-get update
apt-get upgrade -y

# Install prerequisite packages
apt-get install -y wget unzip systemd

# Download and install the CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

# In case of missing dependencies
apt-get install -f -y

# Configure and start the CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c "ssm:${aws_ssm_parameter_cw_agent_config_name}"


# Enable and start the service using systemctl
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Clean up downloaded files
rm -f amazon-cloudwatch-agent.deb

# Verify installation
systemctl status amazon-cloudwatch-agent
