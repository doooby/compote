#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/compote'
require_relative '../lib/compote/cli'

Compote.with_gracious_interrupt do
  command = ARGV.shift
  Compote::Cli.commands.run! command, ARGV
end
