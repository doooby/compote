#!/bin/bash
set -e
while read oldrev newrev refname
do
  jar=$(basename $(realpath ..))
  if [ -f ../.brew_on_push ]; then
    /opt/compote/bin/cli.rb jar $jar brew
  else
    echo -e "\033[33m.brew_on_push is not present\033[0m"
  fi
done
