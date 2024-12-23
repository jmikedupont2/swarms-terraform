# # in python
# open up logs/*.log and read out json

# {
#     "Events": [
#         {
#             "EventId": "3ea90966-2bc7-4d82-a208-91c4b8446f23",
#             "EventName": "GetLogEvents",
#             "ReadOnly": "true",
#             "AccessKeyId": "ASIA5K4H36GT4C65HRZX",
#             "EventTime": 1734818869.0,
#             "EventSource": "logs.amazonaws.com",
#             "Username": "dupont",
#             "Resources": [],
#             "CloudTrailEvent": "{\"eventVersion\":\"1.11\",\"userIdentity\":{\"type\":\"IAMUser\",\"principalId\":\"AIDA5K4H36GT5MJLQHPRT\",\"arn\":\"arn:aws:iam::916723593639:user/dupont\",\"accountId\":\"916723593639\",\"accessKeyId\"

#             CloudTrailEvent is a nested json

# To read JSON data from log files in a directory using Python, you can use the following code snippet:
import json
import glob
log_files = glob.glob('logs/*.log')
all_events = []
for log_file in log_files:
    with open(log_file, 'r') as f:
        try:
            event_data = json.load(f)
        except Exception as e:
            print(log_file,e)
        e1 = event_data.get("Events", [])
        for e in e1:
            print(e1)
            #all_events.extend(e1)

#print(all_events)  # or process the events as needed

# ### Explanation:
# 1. **glob** is used to match all log files in the `logs` directory.
# 2. The code reads each log file line by line and attempts to decode each line as JSON.
# 3. Any parsed events are collected in the `all_events` list.
# 4. Handle JSON decoding errors gracefully.



#                 import boto3, argparse, json
# from datetime import datetime, timedelta

# # Parse command line arguments
# parser = argparse.ArgumentParser(description='Generate an IAM policy based on CloudTrail events.')
# parser.add_argument('--service', dest='service_name', required=True,
#                     help='The name of the AWS service to generate a policy for (e.g., "ec2", "s3", "lambda", etc.)')
# parser.add_argument('--region', dest='region_name', required=True,
#                     help='The AWS region to search for CloudTrail events in')
# parser.add_argument('--hours', dest='hours_ago', type=int, default=2,
#                     help='The number of hours to look back in the CloudTrail events (default is 2)')
# args = parser.parse_args()

# # Initialize CloudTrail client
# client = boto3.client('cloudtrail', region_name=args.region_name)

# # Calculate start time for CloudTrail lookup
# start_time = datetime.utcnow() - timedelta(hours=args.hours_ago)

# # Dictionary to store permissions by service
# permissions_by_service = {}

# # Paginate through CloudTrail events
# for response in client.get_paginator('lookup_events').paginate(
#         StartTime=start_time,
#         EndTime=datetime.utcnow(),
#         LookupAttributes=[
#             {
#                 'AttributeKey': 'EventSource',
#                 'AttributeValue': f'{args.service_name}.amazonaws.com'
#             }
#         ]
# ):
#     # Iterate through events and extract permissions
#     for event in response['Events']:
#         permission = event['EventName']
#         if ":" in permission:
#             service, action = permission.split(':')
#         else:
#             service = args.service_name
#             action = permission
#         permissions_by_service.setdefault(service, set()).add(action)

# # Create policy statement
# policy = {
#     "Version": "2012-10-17",
#     "Statement": []
# }

# # Iterate through permissions by service and add to policy statement
# for service, actions in permissions_by_service.items():
#     statement = {
#         "Sid": "VisualEditor0",
#         "Effect": "Allow",
#         "Action": [f"{service}:{action}" for action in actions],
#         "Resource": "*"
#     }
#     policy["Statement"].append(statement)

# # Print policy in JSON format
# print(f"last: {args.hours_ago}h")
# print(f"service name filter: {args.service_name}")
# print(json.dumps(policy, indent=4))
