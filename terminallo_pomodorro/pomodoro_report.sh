 #!/bin/bash

report_file="/tmp/pomodorro_report_$(date +%Y%m%d%H%M%S).html"
projects_file="/home/skordas/code/looney-tunes/terminallo_pomodorro/projects"
log_directory="/home/skordas/.terminallo_pomodorro/"
days_in_past=30

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

function get_preety_long_date() {
  days=$(($1/1440))
  mod=$(($1%1400))
  hours=$(($mod/60))
  minutes=$(($mod%60))
  echo -e "${days}d ${hours}h ${minutes}m"
}

function get_preety_short_date() {
  hours=$(($1/60))
  minutes=$(($1%60))
  echo -e "${hours}h ${minutes}m"
}

function get_time() {
  hours=$(($1/60))
  minutes=$(($1%60))
  if [[ "$minutes" -lt "10" ]]
  then
    minutes=$(echo "0$minutes")
  fi

  echo -e "${hours}:${minutes}"
}

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
      bar_box="<div class=\"background-0 bar-box inline\" style=\"width: ${bar_time}px\"></div>"
      bar=$(echo -e $bar$bar_box)
      bar_box="<div class=\"background-$id bar-box inline\" style=\"width: ${pomodoro_time}px\"><div class=\"pomodoro-info background-$id\"><p>${project_name[$i]}</p><p>$(get_time $pomodoro_start) - $(get_time $pomodoro_end)</p></div></div>"
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
  echo -e "  <div class=\"inline day-row-day\"></div>"
  echo -e "  <div class=\"inline\">"
  echo -e "    <div class=\"first-top-hour\">0:00</div><div class=\"top-hour\">2:00</div><div class=\"top-hour\">04:00</div><div class=\"top-hour\">06:00</div><div class=\"top-hour\">08:00</div><div class=\"top-hour\">10:00</div><div class=\"top-hour\">12:00</div><div class=\"top-hour\">14:00</div><div class=\"top-hour\">16:00</div><div class=\"top-hour\">18:00</div><div class=\"top-hour\">20:00</div><div class=\"top-hour\">22:00</div>"
  echo -e "  </div>"
  echo -e "</div>"
  for i in ${!preety_day_format[@]}
  do
    echo -e "<div class=\"day-row\">"
    echo -e "<div class=\"inline day-row-day\">"
    echo -e "  <div class=\"inline preety-day-format\">${preety_day_format[$i]}</div>"
    echo -e "  <div class=\"inline time-daily\">$(get_preety_short_date ${time_daily[$i]})</div>"
    echo -e "</div>"
    echo -e "  <div class=\"inline daily-bar\">${daily_bar[$i]}</div>"
    echo -e "</div>"
  done
}

function generate_time_per_project_report() {
  all_time=0
  for i in ${time_per_project[@]}
  do
    all_time=$(($all_time+$i))
  done
  echo -e "<div>All time: $(get_preety_long_date $all_time)</div>"
  for i in ${!project_name[@]}
  do
    percentage=$((${time_per_project[$i]}*100/$all_time))
    echo -e "<div class=\"project-row\">"
    echo -e "<div class=\"inline background-${project_id[$i]} project-time-bar\" style=\"width: ${percentage}%\">${percentage}%</div>"
    echo -e "<div class=\"inline color-${project_id[$i]} project-name\">$(get_preety_long_date ${time_per_project[$i]}) : ${project_name[$i]}</div>"
    echo -e "</div>"
  done
}

function generate_daily_distribution_report() {
  echo -e "<div class=\"time-graph\">"
  for i in ${!time_activity[@]}
  do
      echo -e "<div class=\"time-bar float\" style=\"height: $((${time_activity[$i]}*20))px\"></div>"
  done
  echo -e "</div>"
}

cat > $report_file <<- EOM
<!DOCTYPE html>
<html>
  <head>
    <title>Terminallo Pomodorro Raporrto!</title>
    <style>
      body {background-color: #f0f0f0; color: #4f4f4f; font-family: "JetBrains Mono", monospace, ui-monospace; font-size: 14px}
      #header {background-color: #4f4f4f; color: #f0f0f0; text-align: center; font-size: 22px; padding-top: 25px; padding-bottom: 25px}
      .segment {background-color: #fff; margin-top: 10px; padding-top: 5px; padding-bottom: 5px}
      .day-row-day {width: 145px; vertical-align: middle}
      .daily-bar {border: solid 1px #dbdbdb; border-radius: 2px; height: 22px; margin-top: 2px; margin-bottom: 2px; width: 1440px; vertical-align: middle}
      .top-hour {display: inline-block; width: 117px; border-left: solid 1px #dbdbdb; padding-left:2px; font-size: 10px; vertical-align: top}
      .first-top-hour {display: inline-block; width: 118px; padding-left:2px; font-size: 10px; vertical-align: top}
      .time-daily {text-align: right; width: 60px}
      .bar-box {border-radius: 2px; height: 20px; margin-top: 1px}
      .pomodoro-info {visibility: hidden; position: absolute; top: 8px; left: 8px; font-size: 10px; padding: 5px; color: #f0f0f0}
      .bar-box:hover .pomodoro-info {visibility: visible}
      .time-graph {width: 1440px; margin-left: 155px}
      .time-bar {width: 1px; background-color: #666666; margin-left: 0px; margin-right: 0px; min-height: 1px}
      .project-name {vertical-align: middle}
      .project-time-bar {color: #f0f0f0; text-align: right; font-size: 10px; border-radius: 5px; padding-right: 5px; padding-top: 4px; padding-bottom: 4px; margin-top: 2px; margin-bottom: 2px}
      .inline {display: inline-block}
      .float {float: left}
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

#<div class=\"pomodoro-info\">some info</div>
