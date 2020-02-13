#!/bin/bash

# Usage:
# sh change-wallpaper.sh /path/to/diretory/with/wallpapers/ 5 # time in minutes between wallpaper change

directory=$1
time_period=$(($2*60))

while :
do
    wallpaper=$(ls $directory | shuf -n 1)
    wallpaper_path=$directory/$wallpaper
    gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper_path"
    sleep_time=$(($time_period-$(($(date +%s)%$time_period))))
    sleep $sleep_time
done
