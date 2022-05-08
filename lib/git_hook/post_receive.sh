#!/bin/bash
set -e
while read oldrev newrev refname
do
  script_name=$(basename $(realpath ..))
  cpt script $script_name
done
