#!/bin/bash
input_directory=~/desktime
output_directory=~/desktime
past_days=15

function manage_locked {
  wait_time=$1
  locked=$2

  if [[ "$locked" == "no" ]]; then
    time_unlocked=$(echo "$time_unlocked+$wait_time" | bc)
  else
    time_locked=$(echo "$time_locked+$wait_time" | bc)
  fi
}

function generate_report {
  file=$1
  time_unlocked=0
  time_locked=0

  # Reading line by line
  while IFS=";" read -r time wait_time locked app window name
  do
    manage_locked $wait_time $locked
  done <"$file"

  echo "$file"
  echo "Unlocked:"
  echo "100*$time_unlocked/($time_unlocked+$time_locked)" | bc -l
  echo "locked:"
  echo "100*$time_locked/($time_unlocked+$time_locked)" | bc -l
  echo ""
}


# Checking all days in history
for i in $(seq $past_days -1 0); do
  log_date=$(date +%Y%m%d -d "$i days ago")
  input_file=$input_directory/$log_date.log
  output_file=$output_directory/report_$log_date.txt

  if [ -f "$input_file" ]; then
    generate_report $input_file $output_file
  else
    continue
  fi
done