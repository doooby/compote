# frozen_string_literal: true

require LIB_PATH.join('compote.rb')

module Compote
  module Commands
    module Docker

      def self.run! arguments
        command = arguments.shift
        CommandRunner.new(command).parse! do |parser|
          parser.banner = 'compote-docker [command]'
          parser.on('build', 'Builds the image.') do
            BuildBase.call arguments
          end
          parser.on('up', 'runs the containers in background.') do
            Up.call arguments
          end
          parser.on('down', 'takes down the containers.') do
            Up.call arguments
          end
        end
      end

      module BuildBase
        def self.call arguments
          jar_name = arguments.shift
          jar = Jar.new jar_name
          jar.open_dir!
          jar.clear_for_build!
          image = arguments.shift
          dockerfile_path = jar.prepare_for_build image
          Compote.exec <<-COMMAND
sudo docker build \
  -f #{dockerfile_path} \
  -t #{jar.image_tag image} \
  . \
; \
rm .dockerignore
COMMAND
        end
      end

      module Up
        def self.call arguments
          jar_name = arguments.shift
          jar = Jar.new jar_name
          jar.open_dir!
          Compote.exec "sudo #{jar.command_compose} up -d"
        end
      end

      module Down
        def self.call arguments
          jar_name = arguments.shift
          jar = Jar.new jar_name
          jar.open_dir!
          Compote.exec "sudo #{jar.command_compose} down"
        end
      end

    end
  end
end
