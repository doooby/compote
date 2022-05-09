#!/bin/bash
set -e
while read oldrev newrev refname
do
  script_name=$(basename $(realpath ..))
  if [ -f ../.brew_on_push ]; then
    cpt script $script_name brew
  else
    echo "skipping jar brew on push"
  fi
done
