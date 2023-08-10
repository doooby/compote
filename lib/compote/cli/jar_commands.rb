# frozen_string_literal: true

module Compote
  module Cli

    class << self
      attr_reader :jar_commands
      attr_accessor :jar
    end
    
    @jar_commands = Commands.new
    @jar_commands.banner = 'usage:  compote jar NAME CMD [OPTS]'

    def @jar_commands.run! cmd, args
        if cmd == '-h' || cmd.nil?
          super '-h', args
        else
          name = Cli.shift_jar_name! [cmd]
          Cli.jar = Jar[name]
          super args.shift, args
        end
    end

      @jar_commands.add 'update', 'Updates jar git source' do
        @jar.open_dir!
        @jar.checkout_source!
      end

#       @jar_commands.add 'make_base', 'Crates the base docker images' do
#         jar.build_base
#         Compote.log :green, 'base images built'
#       end
#
      @jar_commands.add 'path', 'prints path in the shelf' do
        puts @jar.path.to_path
      end

      @jar_commands.add 'conf', 'Opens jar.conf in nano' do
        @jar.open_dir!
        exec 'sudo nano jar.conf'
      end
#
#       @jar_commands.add 'up', 'Starts all the containers' do
#         jar.compose 'up -d'
#       end
#
#       @jar_commands.add 'down', 'Stops all the containers' do
#         jar.compose 'down'
#       end
#
#       @jar_commands.add 'compose', 'runs docker compose with arguments' do |args|
#         Compote.exec "#{jar.command_compose} #{args.join ' '}"
#       end
#
#       @jar_commands.add 'bash', 'Runs bash on a temporary container' do
#         Compote.exec "#{jar.command_compose} run --rm app bash"
#       end
#
#       @jar_commands.add 'brew', 'Brews the compote, aka. release' do
#         jar.checkout_source
#         Object.const_set 'JAR', jar
#         require "#{Dir.pwd}/#{Compote::Jar::JAR_SRC_CONFIG_PATH}/recipe.rb"
#         Compote.log :green, 'the compote has been brewed'
#       end

      @jar_commands.add 'auto_brew', 'Sets the git-push mechanism [0,1]' do |args|
        value = shift_param! args, 'pass 0 or 1'
        file = '.brew_on_push'
        if value == '1'
          Compote.run 'sudo touch .brew_on_push'
          Compote.log :green, 'jar will brew on git-push'
        else
          Compote.run 'sudo rm .brew_on_push'
          Compote.log :green, 'brew on git-push is off'
        end
      end

#       @jar_commands.add 'irb', 'Opens ruby console at the jar path' do
#         require 'irb'
#         binding.irb
#       end
  end
end
    