#!/bin/bash
echo <<EOF
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

EOF
set -e
set -x
# Constants
export REGION="${REGION:-us-east-2}"
#export AWS_PROFILE="${AWS_PROFILE:-swarms}"
#export AWS_PROFILE="${AWS_PROFILE}" only needed for testing locally
TAG_KEY="${TAG_KEY:-Name}"

# which servers to target
TAG_VALUE="${TAG_VALUE:-docker-swarms-ami-t3.medium}" 

#what git remote
GIT_URL="${GIT_URL:-https://github.com/jmikedupont/swarms}"

# what to name the repo
export GIT_NAME="${GIT_NAME:-mdupont}"

# what version of swarms to deploy
export GIT_VERSION="${GIT_VERSION:-feature/squash2-docker}" 

# what script to call?
DOCUMENT_NAME="${DOCUMENT_NAME:-deploy-docker}"

# this script is defined in
# environments/call-swarms/main.tf

# what version
DOCUMENT_VERSION="${DOCUMENT_VERSION:-1}"

TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-600}"
MAX_CONCURRENCY="${MAX_CONCURRENCY:-50}"
MAX_ERRORS="${MAX_ERRORS:-0}"

# Function to get instance IDs
get_instance_ids() {
    aws ec2 describe-instances \
        --filters "Name=tag:$TAG_KEY,Values=$TAG_VALUE" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text \
        --region $REGION 
}

# Function to send command to instance
send_command() {
    local instance_id="$1"
    aws ssm send-command \
        --document-name "$DOCUMENT_NAME" \
        --document-version "$DOCUMENT_VERSION" \
        --targets "[{\"Key\":\"InstanceIds\",\"Values\":[\"$instance_id\"]}]" \
        --parameters "{\"GitUrl\":[\"$GIT_URL\"],\"GitName\":[\"$GIT_NAME\"],\"GitVersion\":[\"$GIT_VERSION\"]}" \
        --timeout-seconds $TIMEOUT_SECONDS \
        --max-concurrency "$MAX_CONCURRENCY" \
        --max-errors "$MAX_ERRORS" \
        --region $REGION \
        --output-s3-bucket-name "swarms-session-logs-20241221151754799300000003" \
	--cloud-watch-output-config '{"CloudWatchOutputEnabled":true,"CloudWatchLogGroupName":"/ssm/session-logs-20241221151803393300000006"}'
    
}

# Function to fetch command output
fetch_command_output() {
    local command_id="$1"
    aws ssm list-command-invocations \
        --command-id "$command_id" \
        --details \
        --region $REGION | jq -r '.CommandInvocations[] | {InstanceId, Status, Output}'
}

# Main script execution
for instance in $(get_instance_ids); do
    echo "Instance ID: $instance"
    result=$(send_command "$instance")
    command_id=$(echo $result | jq -r '.Command.CommandId')

    # Wait for the command to complete
    aws ssm wait command-executed --command-id "$command_id" --region $REGION --instance $instance
    
    # Fetch and print the command output
    fetch_command_output "$command_id"
done
