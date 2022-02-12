#!/usr/bin/env ruby
require 'pathname'
LIB_PATH = Pathname.new(__dir__).join '../lib'

require LIB_PATH.join('compote/commands/brew.rb')
Compote::Commands::Brew.run! ARGV
