#!/bin/bash
while read oldrev newrev refname
do
  set -e
  jar_name=$(basename $(realpath ..))
  sudo ../bin/compote-brew.rb $jar_name
done
