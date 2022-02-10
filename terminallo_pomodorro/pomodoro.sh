#!/bin/bash

# TODO download own icons and sounds.
# TODO Add date and time before logging of a new pomodoro and break
# TODO - check correct notification

## Settings
pomodoro_length=25
short_break_length=5
long_break_length=15
long_break_after=4

projects_file="/home/skordas/code/looney-tunes/terminallo_pomodorro/projects"
log_directory="/home/skordas/.terminallo_pomodorro/"
icon_path="/usr/share/icons/breeze/preferences/32/preferences-desktop-notification.svg"
bell_path="/usr/share/sounds/speech-dispatcher/piano-3.wav"

## Colors
red="\e[31m"
green="\e[32m"
reset="\e[0m"

# Entities
pomodoro="pomodoro"
short_break="short_break"
long_break="long_break"

# User's time variables in seconds.
pomodoro_time=$(($pomodoro_length*60))
short_break_time=$(($short_break_length*60))
long_break_time=$(($long_break_length*60))

# Global variables:
global_project_id=""
global_start_time=""
global_end_time=""
global_time_to_end_of_pomodoro=$pomodoro_time

stop_timer=false
stop_pomodoro=false

clean() {
  stop_timer=true
}

trap clean SIGINT

function countdown() {
  stop_timer=false
  sec=$1
  while [ $sec -gt 0 ]
  do
    echo -ne "$(date --date=$(echo "@$sec") -u +'%M:%S')\033[0K\r"
    sleep 1
    : $((sec--))
    if [[ "$stop_timer" == "true" ]]
    then
      global_time_to_end_of_pomodoro=$sec
      break
    fi
  done
  stop_pomodoro=true
}

function display_projects() {
  # Reading line by line
  while IFS=";" read -r project_ID project_name project_color
  do
    echo $project_ID" - "$project_name
  done <"$projects_file"
  echo ""
}

function send_notification() {
  if [[ "$1" == "$pomodoro" ]]
  then
    msg="pomodoro"
  elif [[ "$1" == "$short_break" ]]
  then
    msg="short break"
  elif [[ "$1" == "$long_break" ]]
  then
    msg="long break"
  fi
  aplay -q $bell_path &
  notify-send -u critical -a "Terminallo Pomodorro" -i $icon_path "It's time to..." "Start $msg"
}

function do_pomodoro() {
  stop_pomodoro=false
  while [[ "$stop_pomodoro" == "false"  ]]
  do
    send_notification $pomodoro
    echo -e $red"Choose your project..."$reset
    display_projects
    read project_ID
    global_project_id=$project_ID
    echo -e $red"\nSTARTING POMODORRO! - "$(cat $projects_file | grep $project_ID | cut -d ';' -f 2)$reset
    echo ""

    global_start_time=$(echo "$(date +'%H') * 60 + $(date +'%M')" | bc)
    countdown $global_time_to_end_of_pomodoro
    global_end_time=$(echo "$(date +'%H') * 60 + $(date +'%M')" | bc)
    log_line=$(echo "$global_start_time;$global_end_time;$project_ID")
    log_file_name=$(date +%Y%m%d)
    log_file=$log_directory/$log_file_name.log
    echo $log_line >> $log_file
    ## Verification if needed continue the same pomodoro - starting new project - or just finish pomodoro.
    if [[ "$stop_timer" == "true" ]] && [[ "$stop_pomodoro" == "true" ]]
    then
      echo ""
      read -p "s will stop pomodoro, rest for changing the project" anwser
      if [[ "$anwser" == "s" ]]
      then
        break
      else
        stop_pomodoro=false
      fi
    fi
  done
}

function do_break() {
  local break_time
  local break_name
  local break_type

  if [[ "$1" == "1"  ]]
  then
    break_time=$long_break_time
    break_name="Long break"
    break_type=$long_break
  else
    break_time=$short_break_time
    break_name="Short break"
    break_type=$short_break
  fi

  send_notification $break_type
  echo -e $green$break_name$reset
  read -p ""
  countdown $break_time
}

function run_pomodoro_cycle() {
  for i in $(seq $long_break_after -1 1)
  do
  global_time_to_end_of_pomodoro=$pomodoro_time
   do_pomodoro
   do_break $i
  done
}

# Terminallo Pomodorro run!
while :
do
  run_pomodoro_cycle
done
