# frozen_string_literal: true

module Compote
  module Cli
    module Jar

      def self.shift_jar_name args
        CommandRunner.shift_parameter! args, 'pass new name'
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
      end

      command_runner.banner = 'usage:  compote jar NAME COMMAND [OPTS]'

      add_command 'update', 'Updates jar git source' do
        jar = with_jar! name
        jar.checkout_source
      end

      add_command 'make_base', 'Crates the base docker images' do
        jar = with_jar! name
        jar.build_base
        Compote.log :green, 'base images built'
      end

      add_command 'serve', 'runs docker compose with arguments' do |args|
        jar = with_jar! name
        jar.serve args
      end

      add_command 'up', 'Starts all the containers' do
        jar = with_jar! name
        jar.serve 'up -d'
      end

      add_command 'down', 'Stops all the containers' do
        jar = with_jar! name
        jar.serve 'down'
      end

      add_command 'bash', 'Runs bash on a temporary container' do
        jar = with_jar! name
        jar.serve 'run --rm app bash'
      end

      add_command 'brew', 'Brews the compote, aka. release' do
        with_jar! name
        require_relative "#{Compote::Jar::JAR_SRC_CONFIG_PATH}/compote.rb"
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
        with_jar! name
        require 'irb'
        binding.irb
      end

    end
  end
end
