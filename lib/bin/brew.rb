require 'pathname'
LIB_PATH = Pathname.new(Dir.pwd).join 'lib'

require LIB_PATH.join('compote/commands/brew.rb')
Compote::Commands::Brew.run! ARGV
