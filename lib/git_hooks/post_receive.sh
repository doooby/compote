#!/bin/bash
set -e
while read oldrev newrev refname
do
  jar_name=$(basename $(realpath ..))
  if [ -f ../.brew_on_push ]; then
    /opt/compote/bin/cli.rb jar $jar_name brew
  else
    echo -e "\033[33m.brew_on_push is not present, skipping jar brew\033[0m"
  fi
done
