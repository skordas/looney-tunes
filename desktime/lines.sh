#!/bin/bash

# Table color and reset
tc="\e[33m"
r="\e[0m"

cols=$(tput cols)
lines=$(tput lines)

function print_first_line() {
  echo -ne "$tc\u2554\u2550$r"
  echo -ne "$1"
  echo -ne "$tc"
  len=$(echo "$1" | wc -L)
  end=$(echo "$cols-$len-1" | bc)
  for i in $(seq 3 $end); do
    echo -ne "\u2550"
  done
  echo -ne "\u2557"
  echo -e "$r"
}

function print_line() {
  reduction=-1
  if [[ "$2" -gt "0" ]]; then
    reduction=$2
  fi
  echo -ne "$tc\u2551 $r"
  echo -ne "$1"
  echo -ne "$tc"
  len=$(echo "$1" | wc -L)
  end=$(echo "$cols+$reduction-$len" | bc)
  for i in $(seq 3 $end); do
    echo -ne " "
  done
  echo -ne "\u2551"
  echo -e "$r"
}

function print_horizontal_line() {
  echo -ne "$tc\u2560\u2550$r"
  echo -ne "$1"
  echo -ne "$tc"
  len=$(echo "$1" | wc -L)
  end=$(echo "$cols-$len-1" | bc)
  for i in $(seq 3 $end); do
    echo -ne "\u2550"
  done
  echo -ne "\u2563"
  echo -e "$r"
}

function print_bottom_line() {
  echo -ne "$tc\u255A"
  for i in $(seq 3 $cols); do
    echo -ne "\u2550"
  done
  echo -ne "\u255D"
  echo -e "$r"
}
