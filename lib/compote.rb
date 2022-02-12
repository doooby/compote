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

  def self.exec system_command
    puts "#{system_command}".blue
    Kernel.exec system_command
  end

  def self.jars_dir!
    @jars_dir ||= begin
      path = STACK_PATH.join 'jars'
      unless Dir.exist? path
        puts "creating jars path at #{path}".green
        Compote.run "mkdir #{path}"
        Compote.run "chown compote:compote #{path}"
      end
      path
    end
  end

  def self.jar_dir! name
    jar = Compote.jars_dir!.join name
    unless Dir.exist? jar
      puts "no jar exists at #{jar}".yellow
      exit 1
    end
    jar
  end

  def self.require_sudo!

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
