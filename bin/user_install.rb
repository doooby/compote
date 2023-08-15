#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/compote'

destination = File.expand_path '~/compote_cli'

if File.exist? destination
    Compote.log :red, "runner already exists: #{destination}"
    exit 1
end

Compote.run "touch #{destination}"
File.write destination, <<-CONTENT
#!/usr/bin/env sh
exec ruby #{LIB_PATH.join '../bin/cli.rb'} "$@"
CONTENT
Compote.run "chmod 500 #{destination}"
Compote.log :green, "added cli entrypoint"

bashrc_path = Pathname.new(File.expand_path '~').join '.bashrc'
File.open bashrc_path, 'a' do |f|
  f.write <<-HEREDOC

# compote
alias compote=#{destination}
alias jar="#{destination} jar"
HEREDOC
end
Compote.log :green, 'added aliases "compote", "jar" to .bashrc'

user = `whoami`
Compote.run <<-COMMAND
if ! grep "^compote:" /etc/group > /dev/null; then
  sudo groupadd compote
fi
sudo usermod -a -G compote #{user}
COMMAND

Compote.log :green, 'done'
Compote.log :green, 'log off and on again.'
