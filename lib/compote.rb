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

  require_relative 'compote/jar'

  def self.with_gracious_interrupt
    yield
  rescue Interrupt
    log :red, "compote interrupted"
  end

  def self.run system_command
    log :blue, "#{system_command.gsub '   ', " \\\n  "}"

    command_out, _, pid = PTY.spawn system_command
    loop do
      $stdout.putc command_out.getc || ''
    rescue Errno::EIO # when spawned process terminates, the io just crashes
      break
    end

    status = Process::Status.wait pid
    unless status.exitstatus.zero?
      log :red, "spawned process exited with #{status.exitstatus}"
      exit status.exitstatus
    end
  end

  def self.exec system_command
    log :blue, "#{system_command.gsub '   ', " \\\n  "}"
    Kernel.exec system_command
  end

  def mute!
    @mute = true
  end

  def log color, text
    puts text.send(color) unless @mute
  end

  def self.choose_jar!
    jars = nil
    Dir.chdir shelf_dir! do
      jars = Dir.glob('*').select{ File.directory? _1 }
    end

    if jars.empty?
      log :red, 'shelf is empty'
      exit 1
    else
      prompt = TTY::Prompt.new
      prompt.select 'Choose jar', jars
    end
  end

  def self.shelf_dir!
    @shelf_dir ||= begin
      path = ENV.fetch 'SHELF_PATH', LIB_PATH.join('tmp/shelf')
      unless Dir.exist? path
        log :yellow, 'creating new shelf for compote jars'
        Compote.run "mkdir -p #{path}"
      end
      Pathname.new path
    end
  end

  def self.ensure_i_am_root!
    unless (%x[whoami]).strip == 'root'
      log :red, "needs to be run as root"
      exit 1
    end
  end

end
