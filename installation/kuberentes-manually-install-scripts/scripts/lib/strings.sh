#!/bin/bash

strings::join() {
  format="$1"
  shift
  elems="$@"

  for e in ${elems[@]}; do
    printf "${format}" "$e"
  done
}

