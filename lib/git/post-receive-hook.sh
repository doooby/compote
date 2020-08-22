#!/bin/bash
while read oldrev newrev refname
do
    set -e

    stack_path=$(realpath ..)
    sudo $stack_path/ops/lib/deploy.sh

done