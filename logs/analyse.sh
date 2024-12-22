#!/bin/bash
echo "Bash version ${BASH_VERSION}..."
for i in {1..100}
do
    grep error errors.txt | grep "does not exist for account"| cut -d: -f${i} | sort | uniq -c | sort -n
done
