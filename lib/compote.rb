# frozen_string_literal: true

require 'byebug' unless ENV['PRODUCTION'] == '1'

require 'pathname'
require 'optparse'
require 'open3'
require 'colorize'

module Compote

  def self.run system_command
    puts "#{system_command}".blue
    output, status = Open3.capture2e system_command
    puts output if output && !output.length.zero?
    unless status.exitstatus.zero?
      puts "Exit #{status.exitstatus}".red
      exit status.exitstatus
    end
  end

end

%w[
  command_runner.rb
  options_parser.rb
]
  .each{ require LIB_PATH.join('compote/', _1) }

STACK_PATH = Pathname.new(ENV.fetch 'STACK_PATH', "#{Dir.pwd}/tmp/stack")
unless Dir.exist? STACK_PATH
  Dir.mkdir STACK_PATH
end
