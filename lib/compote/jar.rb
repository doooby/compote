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

  end
end
