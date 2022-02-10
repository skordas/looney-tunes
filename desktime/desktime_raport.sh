#!/bin/bash
source lines.sh
source time.sh
# a="\e[32m"; for i in $(seq 1 80); do a=$(echo -e "$a="); done; a=$(echo -e "$a\e[31m"); for i in $(seq 1 20); do a=$(echo -e "$a="); done; a=$(echo -e "$a\e[0m"); echo $a
file_name=$1
input_directory=~/desktime
output_directory=~/desktime
bars=$(echo "$cols-4" | bc)

function round()
{
  echo $(printf %.$2f $(echo "scale=$2;(((10^$2)*$1)+0.5)/(10^$2)" | bc))
};

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

  p_u=$(round $(echo "$time_unlocked/($time_unlocked+$time_locked)" | bc -l) 2)
  p_l=$(round $(echo "$time_locked/($time_unlocked+$time_locked)" | bc -l) 2)
  a="\e[32m"
  for i in $(seq 1 $(round $(echo "$bars*$p_u" | bc -l) 0));
  do
    a=$(echo -e "$a\u2588")
  done
  a=$(echo -e "$a\e[31m")
  for i in $(seq 1 $(round $(echo "$bars*$p_l" | bc -l) 0))
  do
    a=$(echo -e "$a\u2588")
  done
  a=$(echo -e "$a\e[0m")
}

# Checking all days in history (going throught all files)
# for i in $(seq $past_days -1 0); do
#   log_date=$(date +%Y%m%d -d "$i days ago")
#   input_file=$input_directory/$log_date.log
#   output_file=$output_directory/report_$log_date.txt

#   if [ -f "$input_file" ]; then
#     generate_report $input_file $output_file
#   else
#     continue
#   fi
# done

# Checking $1 day in history
input_file=$input_directory/$file_name.log
output_file=$output_directory/report_$log_date.txt
if [ -f "$input_file" ]; then
  generate_report $input_file $output_file
else
  echo -e "No $input_file file. Please give date in YYYYMMDD format."
  exit 1
fi

print_first_line " $input_file "
print_line
print_line "Total:    $(sec_to_hours $(echo "$time_unlocked+$time_locked" | bc))"
print_line "Unlocked: $(sec_to_hours $time_unlocked) - $(echo "scale=2; 100*$time_unlocked/($time_unlocked+$time_locked)" | bc -l)%"
print_line "Locked:   $(sec_to_hours $time_locked) - $(echo "scale=2; 100*$time_locked/($time_unlocked+$time_locked)" | bc -l)%"
print_line "$a" 10
print_line
print_bottom_line