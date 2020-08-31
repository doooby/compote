#!/bin/bash
set -e

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

stack_path=$(pwd)
working_dir=$stack_path/src

if [ ! -d $working_dir ]; then
  echo "detected initial push, cloning working directory"
  git clone --single-branch --branch master $stack_path/.git $working_dir
  cd $working_dir
  $stack_path/bin/initialize

else
  cd $working_dir
  git fetch origin
  git reset --hard origin/master
  git clean -fdx
  echo

fi

cd $stack_path
[ -f ./auto_release ] && time -p ./auto_release
