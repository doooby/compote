# frozen_string_literal: true

module Compote
  class Jar
    module Script

      def open_script_dir!
        dir = Compote.script_dir! @name
        Dir.chdir dir
        puts "cd #{dir}".blue
        dir
      end

      def checkout_source!
        Compote.run <<-COMMAND
( \
  cd src && \
  git fetch origin && \
  git reset --hard origin/main && \
  git clean -fdx \
)
COMMAND
      end

    end
  end
end
