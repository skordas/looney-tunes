#!/bin/bash
log_directory=~/desktime
wait_time=10

while :; do
  log_time=$(date +%Y:%m:%d:%H:%M:%S)
  file_name=$(date +%Y%m%d)
  log_file=$log_directory/$file_name.log
  # TODO Get correct session numer.
  locked=$(loginctl show-session 2 | grep IdleHint | cut -d "=" -f 2)

  if [[ "$locked" == "no" ]]; then
  	wm_name=$(xprop -id $(xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}') WM_NAME)
    wm_class=$(xprop -id $(xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}') WM_CLASS)
    name=$(echo $wm_name | cut -d "=" -f 2 | awk '{$1=$1;print}')
    name=$(echo ${name:1:-1})
    window=$(echo $wm_class | awk '{print $3}' | cut -d ',' -f 1)
    window=$(echo ${window:1:-1})
    app=$(echo $wm_class | awk '{print $4}')
    app=$(echo ${app:1:-1})

    log_line=$(echo "$log_time;$wait_time;$locked;$app;$window;$name")
  elif [[ "$locked" == "yes" ]]; then
    log_line=$(echo "$log_time;$wait_time;$locked;"n/a";"n/a";"n/a"")
  fi
  echo $log_line >> $log_file
  sleep $wait_time
done
