# get the lines
gron ./logs/*.log  | grep -i error > report.txt

# now we decode
gron -u < report.txt | jq -r ".Events[]|.CloudTrailEvent" | jq | sort  | uniq -c | sort -n


#gron -u < report.txt | jq -r ".Events[]|.CloudTrailEvent" | jq
