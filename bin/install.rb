#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/bin/base'

destination = ARGV.shift
if destination.nil?
  puts 'use:  bin/install.rb destination'.yellow
  puts 'destination = where to install the user runnable script'
  exit 1
end

prompt = TTY::Prompt.new
unless prompt.yes? "are you sure to install the user binary into #{destination} ?"
  exit 1
end
Compote.run "mkdir -p #{File.dirname destination}"
Compote.run "cp #{LIB_PATH.join 'bin/run_compote.sh'} #{destination}"
Compote.run "chmod u+x #{destination}"

bashrc_path = Pathname.new(File.expand_path '~').join '.bashrc'
File.open bashrc_path, 'a' do |f|
  f.write <<-HEREDOC

# compote
alias cpt=#{File.realpath destination}
HEREDOC
end

user = `whoami`
Compote.run <<-HEREDOC
if ! grep "^compote:" /etc/group > /dev/null; then
  sudo groupadd compote
fi
sudo usermod -a -G compote #{user}
HEREDOC
