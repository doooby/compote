#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
LIB_PATH = Pathname.new(Dir.pwd).join(__FILE__ ).join '../../lib'
require LIB_PATH.join('compote.rb')

# Compote.run 'sl'
begin
  Compote.run 'bin/ansi.rb'
rescue Interrupt
  puts
  puts 'iii'
end
