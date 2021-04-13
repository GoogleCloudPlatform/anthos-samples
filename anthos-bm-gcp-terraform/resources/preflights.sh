#!/bin/bash

LOG_FILE=$(cut -d "=" -f2- <<< $(cat init.vars | grep LOG_FILE))
echo "------------------------------------------------------------------------------"
echo "Checking initialization status of hosts before running bmctl :."
echo "------------------------------------------------------------------------------"
tail -f -n +1 $LOG_FILE | sed "/Successfully completed initialization of host $HOSTNAME\|Failed.*$/ q" | grep --color=never --line-buffered "\[+\] Successfully\|\[-\] Failed"

if grep -Fq "[-] Failed" $LOG_FILE
then
  echo "Atleast one initilization step failed. Please check $LOG_FILE before running bmctl"
  exit 1
else
  echo "Host initialization completed successfully"
  exit 0
fi
