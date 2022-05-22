#!/usr/bin/env bash
exec sudo \
 SHELF_PATH=/var/lib/compote/shelf \
 /opt/compote/bin/cli.rb "$@"
