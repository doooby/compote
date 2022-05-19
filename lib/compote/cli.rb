# frozen_string_literal: true

module Compote
  module Cli

    def self.create_jar
      name = Helpers.shift_parameter!(
        help: 'pass jar name'
      )
      jar_path = Compote.shelf_dir!.join name
      if Dir.exist? jar_path
        puts 'jar already exists'.yellow
        exit 1
      else
        Compote.run "mkdir -p #{jar_path}"
      end

      jar = Compote::Jar.new name
      jar.open_dir!

      # create structure
      Compote.run 'mkdir var'
      Compote.run 'mkdir tmp'

      # create config
      Compote.run 'touch jar.conf'
      puts 'filling-in defaults'
      File.write 'jar.conf', [
        "JAR_NAME=#{jar.name}",
        "JAR_PATH=#{Dir.pwd}",
        nil,
        'RACK_ENV=production',
        'NODE_ENV=production',
        nil
      ].join("\n")
      # config for docker compose
      Compote.run 'ln -s jar.conf .env'

      jar.prepare_git_src
      puts "created jar #{jar.name}".green
      git_path = Pathname.new(Dir.pwd).join('.git').to_s
      puts "push source code to #{git_path.underline}".green
    end

    def self.list_jars
      Compote.run "ls -la #{Compote.shelf_dir!}"
    end

    def self.jar_script
      name = Helpers.shift_parameter!(
        help: 'pass jar name'
      )
      script = Helpers.shift_parameter!(
        help: 'pass script name'
      )
      jar = Compote::Jar.new name
      jar.open_dir!
      Object.const_set 'Jar', jar
      jar.script! script
    end

    def self.open_jar
      name = Helpers.shift_parameter!(
        help: 'pass jar name'
      )
      jar = Compote::Jar.new name
      jar.open_dir!
      Compote.run "#{jar.command_compose}   run --rm app bash"
    end

    def self.upgrade
      Dir.chdir LIB_PATH.join('..') do
        Compote.run 'git pull'
      end
    end

    module Helpers
      def self.shift_parameter! help: , **_
        arg = ARGV.shift
        if arg.nil? || arg == '-h'
          puts help
          exit arg.nil? ? 1 : 0
        end
        arg
      end
    end

  end
end

require_relative 'cli/command_runner'
