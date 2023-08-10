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
    log :blue, "#{cmd.gsub '   ', " \\\n  "}"

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

#   def self.choose_jar!
#     jars = nil
#     Dir.chdir shelf_dir! do
#       jars = Dir.glob('*').select{ File.directory? _1 }
#     end
#
#     if jars.empty?
#       log :red, 'shelf is empty'
#       exit 1
#     else
#       prompt = TTY::Prompt.new
#       prompt.select 'Choose jar', jars
#     end
#   end

#   def self.shelf_dir!
#     @shelf_dir ||= begin
#       path = ENV.fetch 'SHELF_PATH', LIB_PATH.join('tmp/shelf')
#       unless Dir.exist? path
#         log :yellow, 'creating new shelf for compote jars'
#         Compote.run "mkdir -p #{path}"
#       end
#       Pathname.new path
#     end
#   end

end
