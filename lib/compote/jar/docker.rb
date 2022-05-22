# frozen_string_literal: true

module Compote
  class Jar
    module Docker

      IGNORE_FILE = '.dockerignore'

      def image_path image_name
        "#{JAR_SRC_CONFIG_PATH}/images/#{image_name}"
      end

      def image_tag image_name
        "jar--#{@name}--#{image_name}"
      end

      def clear_for_build!
        if File.exist? IGNORE_FILE
          Compote.log :red, "#{IGNORE_FILE} is present."
          Compote.log :white, 'either another build is in progress' +
            ' or the previous one failed.'
          exit 1
        end
      end

      def build_base
        clear_for_build!
        dockerfile_path = prepare_for_build 'base'
        Compote.run <<-COMMAND
docker build \
  -f #{dockerfile_path} \
  -t #{image_tag 'base'} \
  .
        COMMAND
        Compote.run "rm #{IGNORE_FILE}"
      end

      def stack image, options, command
        Compote.run <<-COMMAND
docker run --rm \
  --env-file .env \
  #{options.join '   '} \
  #{image_tag image} \
  bash -c \
  "#{command.strip.gsub '"', '\"'}"
        COMMAND
      end

      def brew image
        clear_for_build!
        dockerfile_path = prepare_for_build image
        Compote.run <<-COMMAND
docker build \
  -f #{dockerfile_path} \
  -t #{image_tag image} \
  --build-arg BASE_IMAGE=#{image_tag 'base'} \
  .
        COMMAND
        Compote.run "rm #{IGNORE_FILE}"
      end

      def compose args
        Compote.run "#{command_compose}   #{args}"
      end

      def prepare_for_build image_name
        path = image_path image_name
        ignore_file = "#{path}/#{IGNORE_FILE}"
        ignore = if File.exists? ignore_file
          File.read ignore_file
        end
        File.write IGNORE_FILE, "*\n#{ignore}"
        "#{path}/Dockerfile"
      end

      def command_compose
        <<-COMMAND.strip
docker compose \
  -f #{JAR_SRC_CONFIG_PATH}/docker-compose.yml \
  --env-file .env \
  -p jar_#{@name}
        COMMAND
      end

    end
  end
end
