# frozen_string_literal: true

require_relative './jar/directory'
require_relative './jar/scripts'
require_relative './jar/docker'

module Compote
  class Jar
    JAR_SRC_CONFIG_PATH = 'src/.compote'

    include Directory
    include Scripts
    include Docker

    attr_reader :name

    def initialize name
      @name = name
    end

    def prepare
      open_dir!

      # create structure
      Compote.run 'mkdir var'
      Compote.run 'mkdir tmp'

      # create config
      Compote.run 'touch jar.conf'
      Compote.log :yellow, 'filling-in defaults'
      File.write 'jar.conf', [
        "JAR_NAME=#{name}",
        "JAR_PATH=#{Dir.pwd}",
        nil,
        'RACK_ENV=production',
        'NODE_ENV=production',
        nil
      ].join("\n")
      # config for docker compose
      Compote.run 'ln -s jar.conf .env'

      prepare_git_src
      Compote.log :green, "created jar #{name}"
    end

  end
end
