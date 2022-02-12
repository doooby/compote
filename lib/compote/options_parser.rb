# frozen_string_literal: true

module Compote
    class OptionsParser

      def initialize arguments
        @arguments = arguments
      end

      def parse! &block
        options_parser = ::OptionParser.new &block
        begin
          options_parser.parse! @arguments
        rescue => e
          puts "error [#{e.class.name}] #{e}".red
          puts "\twhile parsing: #{@arguments}"
          puts
          puts options_parser.help
          exit 1
        end
      end

    end
end
