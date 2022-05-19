#!/usr/bin/env bash
exec sudo \
 BYEBUG=0 \
 SHELF_PATH=/var/lib/compote/shelf \
 /opt/compote/bin/cli.rb "$@"
