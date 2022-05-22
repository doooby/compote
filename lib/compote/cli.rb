# frozen_string_literal: true

module Compote
  module Cli

    require_relative 'cli/command_runner'
    require_relative 'cli/jar'

    class << self
      include CommandRunner::Commandable
    end

    command_runner.banner = 'usage:  compote command [opts]'

    add_command 'new', 'Creates new empty jar' do |args|
      name = Jar.shift_jar_name args
      jar = Jar.get_jar name
      if jar
        Compote.log :red, 'jar already exists'
        exit 1
      else
        Compote.run "mkdir -p #{Compote.shelf_dir!.join name}"
      end
      jar = Jar.get_jar name
      jar.prepare
      git_path = Pathname.new(Dir.pwd).join('.git').to_s
      Compote.log :green, "push source code to #{git_path.underline}"
    end

    add_command 'ls', 'List jars' do
      Compote.run "ls -la #{Compote.shelf_dir!}"
    end

    add_command 'remove', 'Destroys the jar and clears the dir' do |args|
      name = Jar.shift_jar_name args
      jar = Jar.get_jar name
      unless jar
        Compote.log :red, 'jar doesn\'t exsist exists'
        exit 1
      end
      Compote.log :yellow, 'WARNING: stop & clear containers manually before continuing'
      prompt = TTY::Prompt.new
      unless prompt.yes? "are you sure to irreversibly remove jar #{jar.name} ?"
        exit 1
      end
      Dir.chdir '..'
      Compote.run "rm -rf #{jar.name}"
    end

    add_command 'path', 'prints path of the jar' do |args|
      Compote.mute!
      name = Jar.shift_jar_name args
      jar = Jar.get_jar name
      if jar
        jar.open_dir!
        puts Dir.pwd
      end
    end

    add_command 'upgrade', 'Updates this library' do
      Dir.chdir LIB_PATH.join('..') do
        user = `stat --format '%U' .`.strip
        Compote.run "su -c 'git pull' #{user}"
      end
    end

  end
end
