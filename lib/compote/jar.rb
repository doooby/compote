# frozen_string_literal: true

module Compote
  class Jar
    attr_reader :name

    def initialize name
      @name = name
    end

    def self.[] name
       jar = new name
       unless jar.exists?
         Compote.log :red, 'jar doesn\'t exist'
         exit 1
       end
       jar
    end

  end
end

require_relative 'jar/directory'
require_relative 'jar/docker'
require_relative 'jar/git'
