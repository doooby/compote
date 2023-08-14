# frozen_string_literal: true

require 'pathname'
LIB_PATH = Pathname.new(Dir.pwd).join(__FILE__).join('../..').realpath
require LIB_PATH.join('compote').to_s
