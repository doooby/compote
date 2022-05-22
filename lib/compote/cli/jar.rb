# frozen_string_literal: true

module Compote
  module Cli
    module Jar

      def self.shift_jar_name args
        CommandRunner.shift_parameter! args, 'pass jar name'
      end

      def self.get_jar name
        jar_path = Compote.shelf_dir!.join name
        if Dir.exist? jar_path
          Compote::Jar.new name
        else
          nil
        end
      end

      def self.with_jar! name
        jar = get_jar name
        unless jar
          Compote.log :red, 'jar doesn\'t exist'
          exit 1
        end
        jar.open_dir!
        jar
      end

      class << self
        include CommandRunner::Commandable
        attr_accessor :jar
      end

      command_runner.banner = 'usage:  compote jar NAME COMMAND [OPTS]'

      add_command 'update', 'Updates jar git source' do
        jar.checkout_source
      end

      add_command 'make_base', 'Crates the base docker images' do
        jar.build_base
        Compote.log :green, 'base images built'
      end

      add_command 'edit_conf', 'Opens jar.conf in nano' do
        Compote.exec 'nano jar.conf'
      end

      add_command 'compose', 'runs docker compose with arguments' do |args|
        jar.serve args.join(' ')
      end

      add_command 'up', 'Starts all the containers' do
        jar.serve 'up -d'
      end

      add_command 'down', 'Stops all the containers' do
        jar.serve 'down'
      end

      add_command 'bash', 'Runs bash on a temporary container' do
        jar.serve 'run --rm app bash'
      end

      add_command 'brew', 'Brews the compote, aka. release' do
        Object.const_set 'JAR', jar
        require "#{Dir.pwd}/#{Compote::Jar::JAR_SRC_CONFIG_PATH}/recipe.rb"
        Compote.log :green, 'the compote has been brewed'
      end

      add_command 'auto_brew', 'Sets the git-push mechanism [0,1]' do |args|
        value = CommandRunner.shift_parameter! args, 'pass 0 or 1'
        file = '.brew_on_push'
        if value == '1'
          File.write file, '' unless File.exist? file
          Compote.log :green, 'jar will brew on git-push'
        else
          File.delete file if File.exist? file
          Compote.log :yellow, 'brew on git-push is off'
        end
      end

      add_command 'irb', 'Opens ruby console at the jar path' do
        require 'irb'
        binding.irb
      end

    end
  end
end
