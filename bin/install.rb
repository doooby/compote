#!/usr/bin/env ruby
# frozen_string_literal: true

destination = ARGV.shift
if destination.nil?
  puts 'use:  bin/install.rb destination'.red
  exit 1
end

require 'pathname'
LIB_PATH = Pathname.new(Dir.pwd).join(__FILE__ ).join '../../lib'
require LIB_PATH.join('compote.rb')

prompt = TTY::Prompt.new
unless prompt.yes? "are you sure to install the user binary into #{destination} ?"
  exit 1
end
Compote.run "mkdir -p #{File.dirname destination}"
Compote.run "cp #{LIB_PATH.join 'bin/run_compote.sh'} #{destination}"
Compote.run "chmod u+x #{destination}"
File.open '~/.bashrc', 'a' do |f|
  f.write <<-HEREDOC

# compote
alias cpt=#{File.realpath destination}
HEREDOC
end
