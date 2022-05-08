#!/bin/bash
set -e
while read oldrev newrev refname
do
  script_name=$(basename $(realpath ..))
  if [ -f ../.brew_on_push ]
    cpt script $script_name
  fi
done
