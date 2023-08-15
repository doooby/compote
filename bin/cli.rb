#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/bin/base'
require LIB_PATH.join('compote/cli').to_s

Compote.ensure_i_am_root!

Compote.with_gracious_interrupt do
  Compote::Cli.command_runner.run! ARGV.shift, ARGV
end
