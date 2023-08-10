# frozen_string_literal: true

module Compote
  module Cli

    class << self
      attr_reader :commands
    end

    @commands = Commands.new

    @commands.banner = 'usage:  compote CMD [OPTS]'

    @commands.add 'jar', 'jar specific commands' do |args|
        unless args.first == '-h'
            name = shift_param! args, 'jar name missing'
            @jar = Jar[name]
        end
        jar_commands.run! args.shift, args
    #       name = Jar.shift_jar_name args
    #       Jar.jar = Jar.with_jar! name
    #       Jar.command_runner.run! args.shift, args
        end

    @commands.add 'new', 'creates new empty jar' do |args|
        name = shift_param! args, 'jar name missing'
        name = shift_jar_name args
    #       jar = Jar.get_jar name
    #       if jar
    #         Compote.log :red, 'jar already exists'
    #         exit 1
    #       else
    #         Compote.run "mkdir -p #{Compote.shelf_dir!.join name}"
    #       end
    #       jar = Jar.get_jar name
    #       jar.prepare
    #       git_path = Pathname.new(Dir.pwd).join('.git').to_s
    #       Compote.log :green, "push source code to #{git_path.underline}"
    end

    @commands.add 'ls', 'list jars' do
    #       Compote.run "ls -la #{Compote.shelf_dir!}"
    end

    @commands.add 'remove', 'destroys the jar and clears the dir' do |args|
    #       name = Jar.shift_jar_name args
    #       jar = Jar.with_jar! name
    #       Compote.log :yellow, 'WARNING: stop & clear containers manually before continuing'
    #       prompt = TTY::Prompt.new
    #       unless prompt.yes? "are you sure to irreversibly remove jar #{jar.name} ?"
    #         exit 1
    #       end
    #       Compote.run "rm -rf #{Compote.shelf_dir!.join jar.name}"
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
