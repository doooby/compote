# frozen_string_literal: true

module Compote
  module Cli

    def self.create_script
      name = Helpers.shift_parameter!(
        help: 'pass script name'
      )
      script_path = Compote.book_dir!.join name
      if Dir.exist? script_path
        puts "script already exists at #{script_path}".yellow
        exit 1
      else
        Compote.run "mkdir -p #{script_path}"
      end

      jar = Compote::Jar.new name
      jar.open_script_dir!

      # create structure
      Compote.run 'mkdir var'
      Compote.run 'mkdir tmp'

      # create config
      Compote.run 'touch jar.conf'
      puts "providing defaults to #{'jar.conf'.blue}"
      File.write 'jar.conf', jar.default_config

      Helpers.prepare_git_src

      # connect config
      Compote.run 'ln -s jar.conf .env'

      path = Pathname.new(Dir.pwd).join '.git'
      puts "created a jar at #{path.to_s.underline}".green
    end

    def self.list_scripts
      Compote.run "ls -l #{Compote.book_dir!}"
    end

    def self.script_command
      name = Helpers.shift_parameter!(
        help: 'nwy' # TODO write help
      )
      command = Helpers.shift_parameter!(
        help: 'nwy' # TODO write help
      )
      jar = Compote::Jar.new name
      jar.open_script_dir!
      Object.const_set 'Jar', jar
      command! 'script', command
    end

    def self.open_jar
      name = Helpers.shift_parameter!(
        help: 'nwy' # TODO write help
      )
      jar = Compote::Jar.new name
      jar.open_script_dir!
      Compote.exec "#{jar.command_compose}  run --rm app bash"
    end

    def self.upgrade
      Dir.chdir LIB_PATH.join('..') do
        Compote.run "git pull"
      end
    end

    module Helpers

      def self.shift_parameter! help: , **_
        arg = ARGV.shift
        if arg.nil? || arg == '-h'
          puts help
          exit arg.nil? ? 1 : 0
        end
        arg
      end

      def self.prepare_git_src
        puts 'setting up git repository'
        Compote.run 'git init -q --bare .git'

        hook_src = LIB_PATH.join 'hooks/git_post_receive.sh.erb'
        hook_path = '.git/hooks/post-receive'
        raise 'bad'
        File.delete hook_path if File.exist? hook_path
        File.write hook_path, ERB.new(File.read hook_src).result(binding)
        Compote.run "cp #{hook} .git/hooks/post-receive"

        Compote.run 'find .git -type d | xargs chmod 0070'
        Compote.run 'find .git -type f | xargs chmod 060'
        Compote.run 'chmod 070 .git/hooks/post-receive'
      end

      def self.command! scope, name
        dir = "compote/cli/commands/#{scope}"
        command = LIB_PATH.join dir, "#{name}.rb"
        if File.exist? command
          require command
        else
          puts 'no such command found'.red
          commands = nil
          Dir.chdir LIB_PATH.join(dir) do
            commands = Dir.glob('*.rb').map{ _1[0..-4] }
          end
          puts "did you mean any of these:  #{commands.join ' '}"
          exit 1
        end
      end

      def self.choose_script_command jar
        jar.open_script_dir!
        commands = nil
        Dir.chdir LIB_PATH.join('compote/cli/commands/script') do
          commands = Dir.glob('*.rb').map{ _1[0..-4] }
        end
        prompt = TTY::Prompt.new
        command = prompt.select "select command:", commands, filter: true
        Object.const_set 'Jar', jar
        command! 'script', command
      end

    end

  end
end

require_relative 'cli/command_runner'
