#!/bin/bash

LOG_FILE=$(cut -d "=" -f2- <<< $(cat init.vars | grep LOG_FILE))
HOSTNAMES=$(cut -d "=" -f2- <<< $(cat init.vars | grep HOSTNAMES))

function __main__ () {
  echo "------------------------------------------------------------------------------"
  echo "Checking initialization status of hosts before running bmctl :."
  echo "------------------------------------------------------------------------------"

  # set traps to ensure all background processes are cleaned up on exit
  __trap_with_arg__ __cleanup__ SIGINT SIGTERM EXIT
  (__print_loading__ "Checking admin...")&
  tail -f -n +1 $LOG_FILE | sed "/Successfully completed initialization of host $HOSTNAME\|Failed.*$/ q" | grep --color=never --line-buffered "\[+\] Successfully\|\[-\] Failed"

  if grep -Fq "[-] Failed" $LOG_FILE
  then
    echo "[!] Atleast one initilization step failed. Please check $LOG_FILE before running bmctl"
    echo "------------------------------------------------------------------------------"
    exit 1
  else
    echo "[*] Admin workstation initialization completed successfully"
    __cleanup__
  fi

  echo "------------------------------------------------------------------------------"
  echo "Checking control-plane and worker nodes' initialization status"
  echo "------------------------------------------------------------------------------"
  (__print_loading__ "Checking cluster nodes...")&
  __check_cluster_nodes__
  echo "------------------------------------------------------------------------------"
}

function __check_cluster_nodes__ () {
  PIDS=""
  COUNT=0
  for host in $(echo $HOSTNAMES | sed "s/|/ /g")
  do
    if [ "$host" != "$(hostname)" ]; then
      ((COUNT=COUNT+1))
      (__test_over_ssh__ $host)&
      PIDS[${COUNT}]=$!
    fi
  done
  for PID in ${PIDS[*]}; do
    wait $PID
    if [ "$?" == 1 ]
    then
      exit 1
    fi
  done
}

function __test_over_ssh__ () {
  HOST=$1
  sudo ssh -o 'StrictHostKeyChecking no' '-o LogLevel=error' root@$HOST 'tail -f -n +1 /home/tfadmin/init.log | sed "/Successfully completed initialization of host $HOSTNAME\|Failed.*$/ q" | grep --color=never --line-buffered "\[+\] Successfully\|\[-\] Failed" > /dev/null 2>&1' &
  RETVAL=$(sudo ssh -o 'StrictHostKeyChecking no' '-o LogLevel=error' root@$HOST 'grep -Fq "[-] Failed" /home/tfadmin/init.log; echo $?')
  if [ "$RETVAL" == 0 ]
  then
      echo "[!] Host [$HOST] has initialization errors. Please check the init.log file for that host before continuing"
      exit 1
  else
      echo "[*] Host [$HOST] has initialized successfully."
      exit 0
  fi
}

function __cleanup__ () {
  # kill all processes whose parent is this process
  pkill -P $$
  if [ "$1" = "SIGINT" ] || [ "$1" = "SIGTERM" ]; then
    exit 1
  fi
}

function __trap_with_arg__ () {
  FUNC="$1" ; shift
  for SIG ; do
    trap "$FUNC $SIG" "$SIG"
  done
}

function __print_loading__ () {
  LOADING_MSG=$1
  CHARS="/-\|"
  while :; do
    for (( i=0; i<${#CHARS}; i++ )); do
      sleep 0.5
      echo -en "$LOADING_MSG ${CHARS:$i:1}" "\r"
    done
  done
}


# Run the script from main()
__main__ "$@"
