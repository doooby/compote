require 'pathname'
LIB_PATH = Pathname.new(Dir.pwd).join 'lib'

require LIB_PATH.join('compote/commands/jar.rb')
Compote::Commands::Jar.run! ARGV

