# frozen_string_literal: true

# ENV:
# PRODUCTION
# STACK_PATH

require 'byebug' unless ENV['PRODUCTION'] == '1'

require 'pathname'
require 'optparse'
require 'open3'
require 'erb'
require 'colorize'
require 'tty-prompt'

require_relative 'compote/jar'

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

  def self.choose_script!
    scripts = nil
    Dir.chdir book_dir! do
      scripts = Dir.glob('*').select{ File.directory? _1 }
    end

    if scripts.nil? or scripts.empty?
      puts 'book is empty'.yellow
      exit 1
    else
      prompt = TTY::Prompt.new
      prompt.select 'Choose script', scripts
    end
  end

  def self.book_dir!
    @jars_dir ||= begin
      path = STACK_PATH.join 'book'
      unless Dir.exist? path
        puts "starting a book at path #{path}".green
        Compote.run "mkdir #{path}"
        Compote.run "chown compote:compote #{path}"
      end
      path
    end
  end

  def self.script_dir! name
    jar = Compote.book_dir!.join name
    unless Dir.exist? jar
      puts "no script with name #{jar} exists".yellow
      exit 1
    end
    jar
  end

  def self.ensure_i_am_root!
    unless (%x[whoami]).strip == 'root'
      puts "needs to be run as root".yellow
      exit 1
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
