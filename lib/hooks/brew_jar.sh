#!/bin/bash
set -e
jar_name=$1
exec sudo bash -ic "ruby bin/brew.rb $jar_name"
