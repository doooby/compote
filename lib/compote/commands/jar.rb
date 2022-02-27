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

          Compote.run 'mkdir var'
          Compote.run 'mkdir tmp'
          Compote.run 'touch jar.conf'
          Compote.run 'chgrp -R compote .'
          Compote.run 'chmod 750 .'
          Compote.run 'chmod 0770 tmp'
          fill_jar_conf name, jar
          prepare_source name, jar
          Compote.run 'ln -s jar.conf .env'
          Compote.run 'chgrp -h compote .env'

          # close src
          # git clone --single-branch --branch main .git $working_dir

          puts "created a jar at  #{jar.join '.git'}".green
        end

        def self.fill_jar_conf name, path
          puts 'providing defaults to jar.conf'
          File.write 'jar.conf', [
            "JAR_NAME=#{name}",
            "JAR_PATH=#{path}",
            nil,
            'RACK_ENV=production',
            'NODE_ENV=production',
            nil
          ].join("\n")
        end

        def self.prepare_source name, path
          puts 'setting up git repository'
          Compote.run 'git init -q --bare .git'
          Compote.run 'chgrp -R compote .git'
          Compote.run 'find .git -type d | xargs chmod 0070'
          Compote.run 'find .git -type f | xargs chmod 060'
          File.delete '.git/hooks/post-receive'
          # Compote.run 'chgrp -h compote .git/hooks/post-receive'
        end
      end

      module Destroy
        def self.call arguments
          name = arguments.shift
          dir = Compote.jar_dir! name
          puts "are you sure to destroy jar #{dir} ?"
          print '[y,n]: '
          input = gets.strip
          puts ">#{input}<"
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
