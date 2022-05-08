# frozen_string_literal: true

module Compote
  class Jar
    module Docker

      def image_path image_name
        "#{IMAGES_PATH}/#{image_name}"
      end

      def image_tag image_name
        "jar--#{@name}--#{image_name}"
      end

      def clear_for_build!
        if File.exist? IGNORE_FILE
          puts '.dockerignore is present.'.yellow
          puts 'either another build is in progress' +
            ' or the previous one failed.'
          exit 1
        end
      end

      def build_base
        clear_for_build!
        dockerfile_path = prepare_for_build 'base'
        Compote.exec <<-COMMAND
sudo docker build \
  -f #{dockerfile_path} \
  -t #{jar.image_tag 'base'} \
  . \
; \
rm .dockerignore
        COMMAND
      end

      def stack image, options, command
        Compote.run <<-COMMAND
docker run --rm \
  --env-file .env \  
#{options.map "\n  #{_1}\\"}  #{image_tag image} \
  #{command}
        COMMAND
      end

      def brew image
        clear_for_build!
        dockerfile_path = prepare_for_build image
        Compote.exec <<-COMMAND
docker build \
  -f #{dockerfile_path} \
  -t #{jar.image_tag image} \
  . \
; \
rm #{IGNORE_FILE}
        COMMAND
      end

      def serve args
        Compote.run "#{command_compose} #{args}"
      end

      def prepare_for_build image_name
        path = image_path image_name
        ignore = File.read "#{path}/#{IGNORE_FILE}"
        File.write IGNORE_FILE, "*\n#{ignore}"
        "#{path}/Dockerfile"
      end

      def command_compose
        <<-COMMAND
docker-compose \
  -f src/.compote/docker-compose.yml \
  --env-file .env \
  -p #{@name} \
  \
        COMMAND
      end

    end
  end
end
