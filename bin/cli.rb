#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/bin/base'
require LIB_PATH.join('compote/cli').to_s

Compote.ensure_i_am_root!

Compote.with_gracious_interrupt do
  command = ARGV.shift

  unless command
    script_name = Compote.choose_script!
    jar = Compote::Jar.new script_name
    Compote::Cli::Helpers.choose_script_command jar
    next
  end

  Compote::CommandRunner.new(command).parse! do |parser|
    parser.banner = 'usage:  compote command [opts]'
    parser.on('-h', 'Prints cli help') do
      puts
      puts parser.help
      exit 0
    end
    parser.on('new', 'Creates new empty script') do
      Compote::Cli.create_script
    end
    parser.on('ls', 'List present scripts') do
      Compote::Cli.list_scripts
    end
    parser.on('script', 'Runs a script command') do
      Compote::Cli.script_command
    end
    parser.on('jar', 'opens a shell on jar container') do
      Compote::Cli.open_jar
    end
    parser.on('upgrade', 'updates this library') do
      Compote::Cli.upgrade
    end
    parser.on('path', 'prints source path') do
      puts LIB_PATH.join('..')
    end
  end
end
