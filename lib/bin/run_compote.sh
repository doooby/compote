#!/usr/bin/env bash
export PRODUCTION=1
export BOOK_PATH=/var/compote_book
exec sudo /opt/compote/bin/compote.rb
