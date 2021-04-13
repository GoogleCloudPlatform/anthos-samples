#!/bin/bash

function __loading__ () {
  chars="/-\|"
  while :; do
    for (( i=0; i<${#chars}; i++ )); do
      sleep 0.5
      echo -en "Waiting for completion logs ${chars:$i:1}" "\r"
    done
  done
}

# kill all processes whose parent is this process
cleanup() {
  pkill -P $$
}

LOG_FILE=$(cut -d "=" -f2- <<< $(cat init.vars | grep LOG_FILE))
echo "------------------------------------------------------------------------------"
echo "Checking initialization status of hosts before running bmctl :."
echo "------------------------------------------------------------------------------"

(__loading__)&
tail -f -n +1 $LOG_FILE | sed "/Successfully completed initialization of host $HOSTNAME\|Failed.*$/ q" | grep --color=never --line-buffered "\[+\] Successfully\|\[-\] Failed"
cleanup

if grep -Fq "[-] Failed" $LOG_FILE
then
  echo "Atleast one initilization step failed. Please check $LOG_FILE before running bmctl"
  echo "------------------------------------------------------------------------------"
  exit 1
else
  echo "Host initialization completed successfully"
  echo "------------------------------------------------------------------------------"
  exit 0
fi
