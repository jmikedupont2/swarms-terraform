#!/bin/bash
set -e
set -x
# Constants
export REGION="${REGION:-us-east-2}"
#export AWS_PROFILE="${AWS_PROFILE:-swarms}"
#export AWS_PROFILE="${AWS_PROFILE}" only needed for testing locally
TAG_KEY="${TAG_KEY:-Name}" 
TAG_VALUE="${TAG_VALUE:-test-swarms-ami-t3.medium}"
GIT_URL="${GIT_URL:-https://github.com/kyegomez/swarms}"
export GIT_NAME="${GIT_NAME:-kye}"
export GIT_VERSION="${GIT_VERSION:-master}"

DOCUMENT_NAME="${DOCUMENT_NAME:-deploy}"
DOCUMENT_VERSION="${DOCUMENT_VERSION:-2}"
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
