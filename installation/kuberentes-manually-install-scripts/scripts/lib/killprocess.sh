#!/bin/bash

# -- Kill multiple processes and all of their child processes --

pstree() {
  for pid in $@; do
    echo $pid
    child_pids=$(pschildren ${pid})
    if [ -n "${child_pids}" ]; then
      pstree "${child_pids}"
    fi
  done
}

pschildren() {
  ps -e -o ppid= -o pid= | sed -e 's/^\s*//' -e 's/\s\s*/\t/' | grep -w "^$1" | cut -f2
}

# kill pids
killprocess() {
  [ -z "$@" ] && return
  pids=$(pstree "$@")
  kill -9 $pids &> /dev/null
}

