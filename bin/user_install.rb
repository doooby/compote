#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/bin/base'

cli_path = '/opt/compote/bin/cli.rb'

bashrc_path = Pathname.new(File.expand_path '~').join '.bashrc'
File.open bashrc_path, 'a' do |f|
  f.write <<-HEREDOC

# compote
alias compote=#{cli_path}
alias jar="#{cli_path} jar"
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
