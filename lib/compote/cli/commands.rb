# frozen_string_literal: true

module Compote
  module Cli

    class << self
      attr_reader :commands
    end

    @commands = Commands.new

    @commands.banner = 'usage:  compote CMD [OPTS]'

    @commands.add 'jar', 'jar specific commands' do |args|
        jar_commands.run! args.shift, args
    end

    @commands.add 'new', 'creates new empty jar' do |args|
      name = shift_jar_name! args
      jar = Jar.new name
      if jar.exists?
        Compote.log :red, 'jar already exists'
        exit 1
      else
        Compote.run "sudo mkdir -p #{Compote.shelf_dir!.join name}"
      end
      jar.initialize_jar!
      git_path = Pathname.new(Dir.pwd).join('.git').to_s
      Compote.log :green, "git repository path: #{git_path.underline}"
    end

    @commands.add 'ls', 'list jars' do
    #       Compote.run "ls -la #{Compote.shelf_dir!}"
    end

    @commands.add 'remove', 'destroys the jar and clears the dir' do |args|
      name = shift_jar_name! args
     jar = Jar.new name
     unless jar.exists?
         Compote.log :yellow, 'jar doesn\'t exist'
         exit 0
       end
      Compote.log :yellow, 'WARNING: stop & clear containers manually before you continue'
      prompt = TTY::Prompt.new
      unless prompt.yes? "are you sure to irreversibly remove jar #{jar.name} ?"
        exit 1
      end
      Compote.run "sudo rm -rf #{jar.path}"
    end

    @commands.add 'path', 'prints path of the jar' do |args|
    #       Compote.mute!
    #       name = Jar.shift_jar_name args
    #       Jar.with_jar! name
    #       puts Dir.pwd
    end

    @commands.add 'irb', 'opens irb console with this library' do
      require 'irb'
      binding.irb
    end
  end
end
