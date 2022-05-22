#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/bin/base'
require LIB_PATH.join('compote/cli').to_s

Compote.ensure_i_am_root!

Compote.with_gracious_interrupt do
  command = ARGV.shift

  unless command
    jar = Compote::Jar.new Compote.choose_jar!
    jar.open_dir!
    Object.const_set 'Jar', jar
    jar.script! jar.select_script
    next
  end

  Compote::Cli::CommandRunner.new(command).parse! do |parser|
    parser.banner = 'usage:  compote command [opts]'
    parser.on('-h', 'Prints cli help') do
      puts
      puts parser.help
      exit 0
    end
    parser.on('new', 'Creates new empty jar') do
      Compote::Cli.create_jar
    end
    parser.on('ls', 'List jars') do
      Compote::Cli.list_jars
    end
    parser.on('script', 'Runs a jar script') do
      Compote::Cli.jar_script
    end
    parser.on('jar', 'opens a shell on jar container') do
      Compote::Cli.open_jar
    end
    parser.on('upgrade', 'updates this library') do
      Compote::Cli.upgrade
    end
  end
end
