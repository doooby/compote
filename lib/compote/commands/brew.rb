# frozen_string_literal: true

require LIB_PATH.join('compote.rb')

module Compote
  module Commands
    module Brew

      def self.run! arguments
        unless %x[whoami] == 'root'
          puts "needs to be run as root".yellow
          exit 1
        end

        jar_name = arguments.shift
        jar = Jar.new jar_name
        jar.open_dir!

        Object.const_set 'JAR', jar
        load Compote::Jar::RECIPE_PATH
        puts 'recipe brewed successfully'.green
        Compote.exec "#{jar.command_compose} up -d"
      end

    end
  end
end
