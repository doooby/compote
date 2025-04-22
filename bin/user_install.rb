#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/compote'

cli_path = '/opt/compote/bin/cli.rb'

bashrc_path = Pathname.new(File.expand_path '~').join '.bashrc'
File.open bashrc_path, 'a' do |f|
  f.write <<-HEREDOC

# compote
alias compote=#{cli_path}
alias jar="#{cli_path} jar"
HEREDOC
end
Compote.log :green, 'added aliases "compote" & "jar" to .bashrc'

user = `whoami`
Compote.run <<-COMMAND
# setup the user's group privilege
if ! grep "^compote:" /etc/group > /dev/null; then
  sudo groupadd compote
fi
sudo usermod -a -G compote #{user}

# ignore this git safety measure, we intend to work with the repo using group permisions
git config --global safe.directory "*"
COMMAND

Compote.log :green, 'done'
Compote.log :green, 'log off and on again.'
