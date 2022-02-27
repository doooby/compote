require 'pathname'
LIB_PATH = Pathname.new(Dir.pwd).join 'lib'

require LIB_PATH.join('compote/commands/docker.rb')
Compote::Commands::Docker.run! ARGV
