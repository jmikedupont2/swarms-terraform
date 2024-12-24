Welcome to the the call swarms ssm framework,
it allows invocation of the swarms agent on a remote ssm server via the aws api.
This can be almost any cloud server that is reachable via ssm, that can be on prem
and in theory on another cloud.

The file actions/call_swarms.sh is a Bash script designed to interact with AWS  
services. It sets up environment variables for AWS region, tag keys and values, 
Git repository details, and other parameters. The script defines functions to   
retrieve instance IDs, send commands to instances via AWS SSM, and fetch command
outputs. It iterates over the instances, sends commands, waits for execution,   
and retrieves outputs, logging them to CloudWatch. The script is structured to  
facilitate remote invocation of a swarms agent on cloud servers.                

The script called is defined in `environments/call-swarms/main.tf` and applied in accounts/swarms/ like
```bash
pushd ../../accounts/swarms/
#tofu apply
# apply only the one change
tofu apply -auto-approve --target module.call_swarms.aws_ssm_document.deploy-docker
# terraform apply
popd
```

It includes the file
resource "aws_ssm_document" "deploy" {
  content         = file("${local.codebase_root_path}/environments/call-swarms/deploy.yaml")
it will call
        sudo su -c "bash -e -x /var/swarms/agent_workspace/boot.sh" swarms


and resource "aws_ssm_document" "deploy-docker" {
  ~/swarms-terraform/environments/call-swarms/deploy-docker.yaml
  It will call
  sudo bash -e -x /opt/swarms/api/docker-boot.sh # needs root access

The permissions to call aws from github is applied here in this terraform code
https://github.com/jmikedupont2/terraform-aws-oidc-github/pull/1
