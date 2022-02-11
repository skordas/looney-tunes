 #!/bin/bash

report_file="/tmp/pomodorro_report_$(date +%Y%m%d%H%M%S).html"
projects_file="/home/skordas/code/looney-tunes/terminallo_pomodorro/projects"
log_directory="/home/skordas/.terminallo_pomodorro/"
days_in_past=14

# Projects arrays
project_id=()
project_name=()
project_color=()

# Time related arrays
time_daily=()
time_per_project=()
time_activity=()
preety_day_format=()

# Report related arrays
daily_bar=()

# Iinitilaze time_activity array (each element represent one minute)
for i in $(seq 0 1439)
do
  time_activity+=(0)
done

# Populate projects array from projects file
while IFS=";" read -r id name color
do
  project_id+=("$id")
  project_name+=("$name")
  project_color+=("$color")
  time_per_project+=(0)
done <"$projects_file"

# Populate the rest - based on project
for i in $(seq 0 $days_in_past)
do
  preety_day_format+=($(date "+%m/%d/%g" -d "$i days ago"))
  log_file=$(echo -e "/home/skordas/.terminallo_pomodorro/$(date +%Y%m%d -d "$i days ago").log")
  # Check if file exist
  sum_of_time_daily=0
  bar_start=0
  bar=""
  if [ -f "$log_file" ]; then
    while IFS=";" read -r pomodoro_start pomodoro_end id
    do
      # populate time distribution
      for i in $(seq $pomodoro_start $pomodoro_end)
      do
        time_activity[$i]=$((${time_activity[$i]}+1))
      done

      pomodoro_time=$(($pomodoro_end-$pomodoro_start))
      sum_of_time_daily=$(($sum_of_time_daily+$pomodoro_time))

      # populate time per project
      for i in ${!project_id[@]}
      do
        if [[ "${project_id[$i]}" == "$id" ]]
        then
          time_per_project[$i]=$((${time_per_project[$i]}+$pomodoro_time))
          break
        fi
      done

      # Generate daily bar - need to generate html here - bash is not supporting arrays in arrays. First break - then pomodoro
      bar_time=$(($pomodoro_start-$bar_start))
      bar_box="<div class=\"background-0 bar-box inline\" style=\"width: ${bar_time}px\">.</div>"
      bar=$(echo -e $bar$bar_box)
      bar_box="<div class=\"background-$id bar-box inline\" style=\"width: ${pomodoro_time}px\">.</div>"
      bar=$(echo -e $bar$bar_box)
      bar_start=$pomodoro_end
    done <"$log_file"
  fi
  daily_bar+=("$bar")
  time_daily+=($sum_of_time_daily)
done

function generate_style_per_project() {
  echo -e ".color-0 {color: #fff}"
  echo -e ".background-0 {background-color: #fff}"
  for i in ${!project_id[@]}
  do
    echo -e ".color-${project_id[$i]} {color: #${project_color[$i]}}"
    echo -e ".background-${project_id[$i]} {background-color: #${project_color[$i]}}"
  done
}

function generate_daily_bar_report() {
  echo -e "<div class=\"day-row\">"
  for i in ${!preety_day_format[@]}
  do
    echo -e "<div class=\"inline\">${preety_day_format[$i]}</div>"
    echo -e "<div class=\"inline\">${time_daily[$i]}</div>"
    echo -e "<div class=\"inline\">${daily_bar[$i]}</div>"
  done
  echo -e "</div>"
}

function generate_time_per_project_report() {
  for i in ${!project_name[@]}
  do
    echo -e ${project_name[$i]}
    echo -e ${time_per_project[$i]}
  done
}

function generate_daily_distribution_report() {
  echo -e ${time_activity[@]}
}

cat > $report_file <<- EOM
<!DOCTYPE html>
<html>
  <head>
    <title>Terminallo Pomodorro Raporrto!</title>
    <style>
      body {background-color: #f0f0f0; color: #4f4f4f; font-family: "JetBrains Mono", monospace, ui-monospace;}
      #header {background-color: #4f4f4f; color: #f0f0f0; text-align: center; font-size: 22px; padding-top: 25px; padding-bottom: 25px}
      .segment {background-color: #fff}
      .bar-box {border-radius: 2px}
      .inline {float: left}
      <! --- generate colors per project --->
      $(generate_style_per_project)
    </style>
  </head>
  <body class="main">
    <div id="header">Terminallo Pomodorro Raporrto!</div>
    <div class="report-body">
      <div class="segment">
        $(generate_daily_bar_report)
      </div>
      <div class="segment">
        $(generate_time_per_project_report)
      </div>
      <div class="segment">
        $(generate_daily_distribution_report)
      </div>
      </div>
    </div>
  </body>
</html>
EOM

google-chrome $report_file
