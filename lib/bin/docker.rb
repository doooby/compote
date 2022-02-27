require 'pathname'
LIB_PATH = Pathname.new(__dir__).join '../lib'

require LIB_PATH.join('compote/commands/docker.rb')
Compote::Commands::Docker.run! ARGV
