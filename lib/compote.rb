# frozen_string_literal: true

# ENV:
# PRODUCTION
# BOOK_PATH

require 'byebug' if ENV['DEBUG'] == '1'

require 'pathname'
require 'io/console'
require 'pty'
require 'colorize'
require 'tty-prompt'

unless Object.const_defined? 'LIB_PATH'
  LIB_PATH = Pathname.new(Dir.pwd).join(__FILE__ ).join '..'
end
BOOK_PATH = ENV.fetch 'BOOK_PATH', LIB_PATH.join('tmp/book')

module Compote

  def self.with_gracious_interrupt
    yield
  rescue Interrupt
    puts "compote interrupted".red
  end

  def self.run system_command
    puts "#{system_command.gsub '   ', " \\\n  "}".blue

    command_out, _, pid = PTY.spawn system_command
    loop do
      $stdout.putc command_out.getc || ''
    rescue Errno::EIO # when spawned process terminates, the io just crashes
      break
    end

    status = Process::Status.wait pid
    unless status.exitstatus.zero?
      puts "spawned process exited with #{status.exitstatus}".red
      exit status.exitstatus
    end
  end

  # TODO rename to recipes
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

  # TODO rename to recipes_book_dir!
  def self.book_dir!
    @jars_dir ||= begin
      path = Pathname.new File.realpath(BOOK_PATH)
      unless Dir.exist? path
        puts "starting a book at path #{path}".green
        Compote.run "mkdir -p #{path}"
      end
      path
    end
  end

  def self.script_dir! name
    jar = Compote.book_dir!.join name
    unless Dir.exist? jar
      puts "no script with name #{name} exists".yellow
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

require_relative 'compote/jar'
