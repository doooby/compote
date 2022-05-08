# frozen_string_literal: true

module Compote
  class Jar
    IMAGES_PATH = 'src/.compote/images'
    IGNORE_FILE = '.dockerignore'
    RECIPE_PATH = 'src/.compote/recipe.rb'

    include Script
    include Docker

    attr_reader :name

    def initialize name
      @name = name
    end

    # def images
    #   images = Dir.glob("#{IMAGES_PATH}/*/").map{ _1[0..-2] }
    #   images.delete 'app-base'
    # end

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
