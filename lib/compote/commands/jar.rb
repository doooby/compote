# frozen_string_literal: true

require LIB_PATH.join('compote.rb')
require LIB_PATH.join('compote/jar.rb')

module Compote
  module Commands
    module Jar

      def self.run! arguments
        command = arguments.shift
        CommandRunner.new(command).parse! do |parser|
          parser.banner = 'compote-jar [command]'
          parser.on('list', 'lists jars') do
            List.call arguments
          end
          parser.on('create', 'create a jar') do
            Create.call arguments
          end
          parser.on('destroy', 'destroys a jar') do
            Destroy.call arguments
          end
          parser.on('console', 'opens irb session in the jar') do
            Console.call arguments
          end
        end
      end

      module List
        def self.call _
          Compote.run "ls -l #{Compote.jars_dir!}"
        end
      end

      module Create
        def self.call arguments
          dir = Compote.jars_dir!
          name = arguments.shift
          jar = dir.join name
          if Dir.exist? jar
            puts "jar already exists at #{jar}".yellow
            exit 1
          end

          jar_dir = dir.join name
          Compote.run "mkdir -p #{jar_dir}"
          jar = Compote::Jar.new name
          jar.open_dir!

          # create structure
          Compote.run 'mkdir var'
          Compote.run 'mkdir tmp'

          # create config
          Compote.run 'touch jar.conf'
          puts "providing defaults to #{'jar.conf'.blue}"
          File.write 'jar.conf', jar.default_config

          # correct ownership
          Compote.run 'chgrp -R compote .'
          Compote.run 'chmod 750 .'
          Compote.run 'chmod 0770 tmp'

          prepare_git_src jar

          # connect config
          Compote.run 'ln -s jar.conf .env'
          Compote.run 'chgrp -h compote .env'

          path = Pathname.new(Dir.pwd).join('.git').underline
          puts "created a jar at #{path}".green
        end

        def self.prepare_git_src jar
          puts 'setting up git repository'
          Compote.run 'git init -q --bare .git'
          Compote.run 'chgrp -R compote .git'
          Compote.run 'find .git -type d | xargs chmod 0070'
          Compote.run 'find .git -type f | xargs chmod 060'
          # File.delete '.git/hooks/post-receive'
          # Compote.run 'chgrp -h compote .git/hooks/post-receive'
        end
      end

      module Destroy
        def self.call arguments
          name = arguments.shift
          dir = Compote.jar_dir! name
          puts "are you sure to destroy jar #{dir.to_s.blue} ?"
          print '[y,n]: '
          input = gets.strip
          Compote.run "rm -r #{dir}" if input == 'y'
        end
      end

      module Console
        def self.call arguments
          name = arguments.shift
          jar = Compote::Jar.new name
          jar.open_dir!
          require 'irb'
          binding.irb
          puts 'done'
        end
      end

    end
  end
end
