# frozen_string_literal: true

module Compote
  module Cli

    def self.shift_param! args, message
       value = args.shift
       unless value
         Compote.log :red, message
         exit 1
       end
       value
     end

      def self.shift_jar_name args
        shift_param! args, 'jar name missing'
      end

      def self.get_jar name
        raise 'niy'
#         jar_path = Compote.shelf_dir!.join name
#         if Dir.exist? jar_path
#           Compote::Jar.new name
#         else
#           nil
#         end
      end

      def self.with_jar! name
      raise 'niy'
#         jar = get_jar name
#         unless jar
#           Compote.log :red, 'jar doesn\'t exist'
#           exit 1
#         end
#         jar.open_dir!
#         jar
      end

    class Commands

      attr_accessor :banner
      attr_accessor :items

      def initialize
        @items = []
        @items.push [
          '-h',
          'Prints help',
          ->(_) { puts help }
        ]
      end

      def run! cmd, arguments
        command = find cmd
        if command
          command.call arguments
        else
          Compote.log :yellow, "unknown command #{cmd}" unless cmd.nil?
          puts help
          exit 1
        end
      end

      def find name
        command = items.find{ name == _1[0] }
        return nil unless command
        command[2]
      end

      def help
        longest_command, *_ = items.max_by{ _1[0].length }
        [
          banner,
          "\n",
          'commands:',
          *(items.map do |name, caption|
            spaces = longest_command.length + 2 - name.length
            "#{name}#{' ' * spaces}#{caption}"
          end),
        ].compact
      end

      def add cmd, caption, &block
        items.push [ cmd, caption, block ]
      end

    end

    require_relative 'cli/commands'
    require_relative 'cli/jar_commands'

  end
end
