#!/bin/bash
set -e
jar_name=$1
exec sudo ruby bin/brew.rb $jar_name
