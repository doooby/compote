# frozen_string_literal: true

module Compote
  class Jar
    IMAGES_PATH = 'src/.compote/images'
    IGNORE_FILE = '.dockerignore'
    RECIPE_PATH = 'src/.compote/recipe.rb'

    attr_reader :name

    def initialize name
      @name = name
    end

    def open_dir!
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

    def image_path image_name
      "#{IMAGES_PATH}/#{image_name}"
    end

    def image_tag image_name
      "jar--#{@name}--#{image_name}"
    end

    def images
      images = Dir.glob("#{IMAGES_PATH}/*/").map{ _1[0..-2] }
      images.delete 'app-base'
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

    def default_config
      [
        "JAR_NAME=#{name}",
        "JAR_PATH=#{Dir.pwd}",
        nil,
        'RACK_ENV=production',
        'NODE_ENV=production',
        nil
      ].join "\n"
    end

  end
end
