# Description: Bash script to retrieve logs using AWS CloudTrail.
# Author: <Your Name>
# Date: 2024-12-22

# [--end-time <value>]
# [--event-category <value>]
# [--cli-input-json <value>]
# [--starting-token <value>]
# [--page-size <value>]
# [--max-items <value>]
# [--generate-cli-skeleton <value>]
# [--debug]
# [--endpoint-url <value>]
# [--no-verify-ssl]
# [--no-paginate]
# [--output <value>]
# [--query <value>]
# [--profile <value>]
# [--region <value>]
# [--version <value>]
# [--color <value>]
# [--no-sign-request]
# [--ca-bundle <value>]
# [--cli-read-timeout <value>]
# [--cli-connect-timeout <value>]


# Get today's date in YYYYMMDDHHMM format
#LOG_DATE=$(date -d "today" +"%Y%m%d%H%M")

# Find the latest log file
LATEST_LOG=$(ls logs/*.log 2>/dev/null | tail -n 1)

echo LATEST_LOG $LATEST_LOG


FILENAME=$(ls -t logs/*.log | head -1)
# Extract the start time of the latest log file
NEW_DATE=$(date -u -r ${FILENAME} +%FT%TZ)
echo NEW_DATE $NEW_DATE

# now look for the latest logs/$(date -d "today" +"%Y%m%d%H%M").log files and get the start time of them and use that -10 seconds to start the new one, we want all events newer than our latest
# --max-items 1000
aws cloudtrail lookup-events  --profile swarms --region us-east-2  --start-time $NEW_DATE  --output json >>  logs/$(date -d "today" +"%Y%m%d%H%M").log
