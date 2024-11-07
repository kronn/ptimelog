#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'


state=$(cut -d: -f2 /proc/acpi/button/lid/LID/state | xargs)

timestamp=$(date +'%F %R')
timelog_txt="/absolute/path/to/.local/share/gtimelog/timelog.txt"

case $state in
  'open')
    echo "$timestamp: laptop opened **" >> $timelog_txt
    ;;

  'closed')
    last=$(tail -n5 "$timelog_txt" | grep -v '^$' | tail -n1 | cut -d: -f1,2)
    recent=$(date --date '3 minutes ago' +'%F %R')

    if [[ $last < $recent ]]; then
      echo "$timestamp: laptop closed" >> $timelog_txt
    fi
    ;;
esac
