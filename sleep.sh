#!/bin/bash

DEFAULT_SLEEP_TIME=30
SLEEP_TIME=${1:-${DEFAULT_SLEEP_TIME}}

echo "Sleeping indefinitely until I receive a SIGINT, SIGTERM, or SIGUSR1 ..."

trap "echo 'Recevied a signal, exiting' ; echo $(date) ; exit" SIGINT SIGTERM SIGUSR1

while true; do
  echo "Sleep for ${SLEEP_TIME} seconds..."
  sleep ${SLEEP_TIME}
done
