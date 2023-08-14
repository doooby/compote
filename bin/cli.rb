#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/bin/base'
require LIB_PATH.join('compote/cli').to_s

Compote.ensure_i_am_root!

Compote.with_gracious_interrupt do
  command = ARGV.shift

  if command
    Compote::Cli.command_runner.run! command, ARGV

  else
    # jar = Compote::Jar.new Compote.choose_jar!
    # jar.open_dir!
    # Object.const_set 'Jar', jar
    # jar.script! jar.select_script
    raise 'niy'

  end
end
