#!/usr/bin/env bash
exec sudo \
 DEBUG=0 \
 BOOK_PATH=/var/compote_book \
 /opt/compote/bin/compote.rb "$@"
