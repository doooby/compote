# frozen_string_literal: true

module Compote
  class Jar
    module Scripts

      def script! name
        dir = 'compote/jar/scripts'
        command = LIB_PATH.join dir, "#{name}.rb"
        if File.exist? command
          require command
        else
          puts 'no such command found'.red
          commands = nil
          Dir.chdir LIB_PATH.join(dir) do
            commands = Dir.glob('*.rb').map{ _1[0..-4] }
          end
          puts "commands:  #{commands.join ' '}"
          exit 1
        end
      end

      def select_script
        scripts = nil
        Dir.chdir LIB_PATH.join('compote/jar/scripts') do
          scripts = Dir.glob('*.rb').map{ _1[0..-4] }
        end
        prompt = TTY::Prompt.new
        prompt.select "select script:", scripts, filter: true
      end

    end
  end
end
