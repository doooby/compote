#!/bin/bash
while read oldrev newrev refname
do
    set -e
    cd ..
    sudo ./deploy
done
