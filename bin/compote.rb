#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
LIB_PATH = Pathname.new(Dir.pwd).join(__FILE__ ).join '../../lib'
require LIB_PATH.join('compote.rb')
require LIB_PATH.join('compote/cli.rb')

Compote.ensure_i_am_root!

command = ARGV.shift
if command
  Compote::CommandRunner.new(command).parse! do |parser|
    parser.banner = 'compote command [opts]'
    parser.on('-h', 'Prints cli help') do
      # TODO docs
      puts 'not written yet'
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
    parser.on('path', 'updates this library') do
      puts LIB_PATH.join('..')
    end
  end
else
  script_name = Compote.choose_script!
  jar = Compote::Jar.new script_name
  Compote::Cli::Helpers.choose_script_command jar
end