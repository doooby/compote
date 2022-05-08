# frozen_string_literal: true

module Compote
  class Jar
    JAR_CONFIG_PATH = 'src/.jar'
    JAR_RECIPE_FILE = "#{JAR_CONFIG_PATH}/recipe.rb"
    IGNORE_FILE = '.dockerignore'

    require_relative './jar/script'
    include Script
    require_relative './jar/docker'
    include Docker

    attr_reader :name

    def initialize name
      @name = name
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
