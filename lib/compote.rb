# frozen_string_literal: true

# ENV:
# PRODUCTION
# SHELF_PATH

require 'byebug' if ENV['BYEBUG'] == '1'

require 'pathname'
require 'io/console'
require 'pty'
require 'colorize'
require 'tty-prompt'

unless Object.const_defined? 'LIB_PATH'
  LIB_PATH = Pathname.new(Dir.pwd).join(__FILE__ ).join '..'
end

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

  def self.choose_jar!
    jars = nil
    Dir.chdir shelf_dir! do
      jars = Dir.glob('*').select{ File.directory? _1 }
    end

    if jars.empty?
      puts 'shelf is empty'.yellow
      exit 1
    else
      prompt = TTY::Prompt.new
      prompt.select 'Choose jar', jars
    end
  end

  def self.shelf_dir!
    @shelf_dir ||= begin
      path = ENV.fetch 'SHELF_PATH', LIB_PATH.join('tmp/shelf')
      path = Pathname.new File.realpath(path)
      unless Dir.exist? path
        puts "creating new shelf for jars at path #{path}".yellow
        Compote.run "mkdir -p #{path}"
      end
      path
    end
  end

  def self.ensure_i_am_root!
    unless (%x[whoami]).strip == 'root'
      puts "needs to be run as root".yellow
      exit 1
    end
  end

end

require_relative 'compote/jar'
