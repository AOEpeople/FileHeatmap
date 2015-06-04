#!/bin/bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

WEBSERVERUSER='www-data'
PROGRAMNAME='apache2'

function usage {
    echo "Usage:"
    echo " $0 [-u <user>] [-p <process>]"
    echo " -u webserver user (defaults to 'www-data', but you might want to use 'root' if you want all processes instead of a single worker)"
    echo " -p process name (defaults to 'apache2')"
    echo ""
    exit $1
}

while getopts 'u:p:' OPTION ; do
case "${OPTION}" in
        u) WEBSERVERUSER="${OPTARG}";;
        p) PROGRAMNAME="${OPTARG}";;
        \?) echo; usage 1;;
    esac
done


while true; do
  PID=$(pgrep -u $WEBSERVERUSER $PROGRAMNAME | sort -n | head -1)
  echo "# Start stracing $PID"

  # strace -s 0 -fp $PID -e open 2>&1 | grep '\.php\|\.phtml\|\.xml\|\.js\|\.css' | sed -e 's/.*"\(.*\)".*/\1/'
  # strace -s 0 -fp $PID -e open 2>&1 | sed -e 's/.*"\(.*\)".*/\1/'
  strace -s 0 -fp $PID -e open 2>&1 | grep -v ENOENT | grep -v '\.htaccess' | sed -e 's/.*"\(.*\)".*/\1/'

  echo "# $PID died. Waiting..."
  sleep 10;
done

echo "# No more workers found";
