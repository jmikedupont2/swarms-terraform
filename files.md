Readmes

./README.md
./accounts/swarms/Readme.md
./environments/swarms-aws-agent-api/dev/us-east-1/components/Readme.md
./environments/swarms-aws-agent-api/dev/us-east-1/Readme.md
./environments/swarms-aws-agent-api/dev/us-east-1/components/application_load_balancer/Readme.md
./environments/swarms-aws-agent-api/dev/us-east-1/components/autoscaling_group/Readme.md

Main api component 
./environments/swarms-aws-agent-api/dev/us-east-1/main.tf

asg
./environments/swarms-aws-agent-api/dev/us-east-1/components/autoscaling_group/main.tf

Launch Template
./environments/swarms-aws-agent-api/dev/us-east-1/components/launch_template/main.tf

Load Balancer
./environments/swarms-aws-agent-api/dev/us-east-1/components/application_load_balancer/main.tf
./environments/swarms-aws-agent-api/dev/us-east-1/components/application_load_balancer/route53/main.tf
./environments/swarms-aws-agent-api/dev/us-east-1/components/application_load_balancer/https/main.tf
./environments/swarms-aws-agent-api/dev/us-east-1/components/application_load_balancer/target_group/main.tf

Roles:
./environments/swarms-aws-agent-api/dev/us-east-1/components/roles/main.tf
./environments/swarms-aws-agent-api/dev/us-east-1/components/security/main.tf
./environments/swarms-aws-agent-api/dev/us-east-1/components/vpc/main.tf
./environments/swarms-aws-agent-api/dev/us-east-1/components/keypairs/main.tf

Example Another app

./environments/swarms-deploy/dev/us-east-1/components/launch_template/main.tf
./environments/swarms-deploy/dev/us-east-1/components/autoscaling_group/main.tf
./environments/swarms-deploy/dev/us-east-1/main.tf
./environments/swarms-deploy/main.tf

Setup SSM access

./modules/aws/ssm/setup/main.tf
./modules/aws/ssm/observability/jobs/main.tf
./modules/aws/ssm/observability/install.sh
./modules/aws/ssm/observability/main.tf
./modules/github/actions/aws/policy/main.json

Stage 1
Producing AMI
./environments/swarms-aws-agent-api/dev/us-east-1/components/machine_image/Readme.md
./environments/swarms-aws-agent-api/dev/us-east-1/components/machine_image/variables.tf
./environments/swarms-aws-agent-api/dev/us-east-1/components/machine_image/ubuntu-fastapi.pkr.hcl
./environments/swarms-aws-agent-api/dev/us-east-1/components/machine_image/versions.tf
./environments/swarms-aws-agent-api/dev/us-east-1/components/machine_image/main.tf


Call from github

./accounts/swarms/github/main.tf
./environments/call-swarms/deploy.yaml
./environments/call-swarms/main.tf

./.github/workflows/call-swarms.yml
./.github/workflows/terraform-validate.yml
./.github/workflows/terraform-security-check.yml
./actions/call_swarms.sh


Observability

./logs/logs/202412211604.log
./logs/getlogs.sh


