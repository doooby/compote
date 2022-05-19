#!/usr/bin/env bash
exec sudo \
 BYEBUG=0 \
 RECIPES_BOOK_PATH=/var/lib/compote/book \
 /opt/compote/bin/cli.rb "$@"
