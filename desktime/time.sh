#!/bin/bash

function lz() {
  if [[ "$1" -lt 10 ]]; then
    echo -n "0$1"
  else
    echo -n "$1"
  fi
}

function sec_to_hours() {
  h=$(echo "$1/3600" | bc)
  m=$(echo "($1-$h*3600)/60" | bc)
  s=$(echo "$1-$h*3600-$m*60" | bc)
  echo "$(lz $h):$(lz $m):$(lz $s)"
}

