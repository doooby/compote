# frozen_string_literal: true

require 'pathname'
require 'io/console'
require 'pty'
require 'colorize'
require 'tty-prompt'

LIB_PATH = Pathname.new(__FILE__ ).join '..'

module Compote

  def self.with_gracious_interrupt
    yield
  rescue Interrupt
    log :red, "compote interrupted"
  end

  def self.run cmd
    print '$ '
    cmd.split("\n"){ log :blue, _1 }

    command_out, _, pid = PTY.spawn cmd
    begin
      command_out.each do |line|
        puts line
      end
    rescue Errno::EIO
    end

    status = Process::Status.wait pid
    unless status.exitstatus.zero?
      log :red, "exited with #{status.exitstatus}"
      exit status.exitstatus
    end
  end

  def self.mute!
    @mute = true
  end

  def self.log colorize, text
    puts text.send(colorize) unless @mute
  end

  def self.shelf_dir!
    @shelf_dir ||= begin
      path = '/var/compote_shelf'
      unless Dir.exist? path
        Compote.run "sudo mkdir -p #{path}"
        log :yellow, 'created shelf for compote jars'
      end
      Pathname.new path
    end
  end

end

require_relative 'compote/jar'
