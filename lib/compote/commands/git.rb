# frozen_string_literal: true

require LIB_PATH.join('compote.rb')

module Compote
  module Commands

    module Git

      def self.run! arguments
        command = arguments.shift
        CommandRunner.new(command).parse! do |parser|
          parser.banner = 'compote-git [command] [options]'
          parser.on('list', 'lists jars') do
            List.run! arguments
          end
          parser.on('create', 'create a jar') do
            Create.run! arguments
          end
          parser.on('destroy', 'destroys a jar') do
            Destroy.run! arguments
          end
        end
      end

      def self.jars_dir!
        path = STACK_PATH.join 'jars'
        unless Dir.exist? path
          Compote.run "mkdir #{path}"
          Compote.run "chown compote:compote #{path}"
        end
        path
      end

      module List
        def self.run! _
          Compote.run "ls -l #{Git.jars_dir!}"
        end
      end

      module Create
        def self.run! arguments
          dir = Git.jars_dir!
          jar_name = arguments.shift
          jar = dir.join jar_name
          if Dir.exist? jar
            puts "jar already exists at #{jar}"
            exit 1
          else
            Compote.run "mkdir -p #{jar}"
            puts "opening the jar"
            Dir.chdir jar
            Compote.run 'mkdir var'
            Compote.run 'mkdir tmp'
            Compote.run 'touch jar.conf'
            Compote.run 'chgrp -R compote .'
            Compote.run 'chmod 750 .'
            Compote.run 'chmod 0770 tmp'
            fill_jar_conf jar_name, jar
            prepare_source jar_name, jar
            Compote.run 'ln -s jar.conf .env'
            Compote.run 'chgrp -h compote .env'
            puts "created a jar at  #{jar.join '.git'}".green
          end
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
        def self.run! arguments
          dir = Git.jars_dir!
          jar = dir.join arguments.shift
          unless Dir.exist? jar
            puts "no jar exists at #{jar}"
            return
          end
          puts "are you sure to destroy jar #{jar} ?"
          print '[y,n]: '
          input = gets.strip
          puts ">#{input}<"
          Compote.run "rm -r #{jar}" if input == 'y'
        end
      end

    end

  end
end
