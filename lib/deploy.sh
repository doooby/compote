#!/bin/bash
set -e

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

stack_path=$(realpath ..)
working_dir=$stack_path/src

if [ ! -d $working_dir ]; then
  echo "detected initial push, cloning working directory"
  git clone --single-branch --branch master $stack_path/.git $working_dir
  cd $working_dir
  bash $stack_path/ops/lib/init_stack.sh

else
  cd $working_dir
  git fetch origin
  git reset --hard origin/master
  git clean -fdx
  echo

fi

cd $stack_path
release_hook=$stack_path/deploy
[ -f $release_hook ] && time -p $release_hook
