# frozen_string_literal: true

module Compote
  module Cli
    class CommandRunner

      attr_accessor :banner
      attr_accessor :commands

      def initialize
        @commands = []
        @commands.push [
          '-h',
          'Prints help',
          ->(_) { puts help }
        ]
      end

      def run! command, arguments
        command = find_command command
        if command
          command.call arguments
        else
          puts "unknown command #{command}".yellow
          puts help
          exit 1
        end
      end

      def find_command name_to_find
        command = commands.find do |name, _, _|
          name_to_find == name
        end
        return nil unless command
        _, _, block = command
        block
      end

      def help
        longest_command, _ = commands.max{ _1.length }
        [
          "\n",
          banner,
          'commands:',
          *commands.map{
            name, caption, _ = _1
            spaces = longest_command.length + 2 - name.length
            "#{name}#{' ' * spaces}#{caption}"
          },
        ].compact
      end

      def self.shift_parameter! arguments, help
        arg = arguments.shift
        if arg.nil? || arg == '-h'
          puts help
          exit arg.nil? ? 1 : 0
        end
        arg
      end

      module Commandable

        def command_runner
          @command_runner ||= CommandRunner.new
        end

        def add_command command, caption, &block
          command_runner.commands.push [ command, caption, block ]
        end

      end

    end
  end
end
