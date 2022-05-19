# frozen_string_literal: true

module Compote
  module Cli
    class CommandRunner

      def initialize command
        @command = command
      end

      def parse!
        parser = Parser.new
        yield parser
        command = parser.find_command @command
        unless command
          puts "unknown command #{@command}".yellow
          puts
          puts parser.help
          exit 1
        end
        command.call
      end

      class Parser
        attr_accessor :banner
        attr_reader :commands

        def initialize
          @commands = []
        end

        def on name, caption, &block
          commands.push [ name, caption, block ]
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
          puts [
            banner,
            'commands:',
            *commands.map{
              name, caption, _ = _1
              "#{name}\t#{caption}"
            },
          ].compact
        end
      end

    end
  end
end
