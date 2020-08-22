#!/bin/bash
set -e

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

source ops/libops.sh
libops_print "initializing stack $stack_name"

libops_print -p "init"
init_script=src/.compote/init.sh
if [ ! -f $init_script ]; then
  libops_fail_with << HEREDOC
stack source is missing .compote/init.sh
HEREDOC
fi
source $init_script

libops_print -p "first time build"
build_script=src/.compote/build.sh
if [ ! -f $build_script ]; then
  libops_fail_with << HEREDOC
stack source is missing .compote/build.sh
HEREDOC
fi
source $build_script

libops_print "init of $stack_name finished"
