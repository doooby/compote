#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/bin/base'

destination = '/opt/compote_runner'
Compote.run "cp #{LIB_PATH.join 'bin/cli_runner.sh'} #{destination}"
Compote.run "chmod u+x #{destination}"

bashrc_path = Pathname.new(File.expand_path '~').join '.bashrc'
File.open bashrc_path, 'a' do |f|
  f.write <<-HEREDOC

# compote
alias compote=#{destination}
alias jar="#{destination} jar"
HEREDOC
end
puts 'added alias to .bashrc'.green

user = `whoami`
Compote.run <<-HEREDOC
if ! grep "^compote:" /etc/group > /dev/null; then
  sudo groupadd compote
fi
sudo usermod -a -G compote #{user}
HEREDOC

puts 'done'.green
puts 'log off and on again.'
