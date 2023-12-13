# frozen_string_literal: true

module Compote
  module Cli

    class << self
      attr_reader :jar_commands
      attr_accessor :jar
    end

    @jar_commands = Commands.new
    @jar_commands.banner = 'usage:  compote jar NAME CMD [OPTS]'

    def @jar_commands.run! cmd, args
      if cmd == '-h' || cmd.nil?
        super '-h', args
      else
        name = Cli.shift_jar_name! [cmd]
        Cli.jar = Jar[name]
        super args.shift, args
      end
    end

    @jar_commands.add 'update', 'Updates jar git source' do
      @jar.open_dir!
      @jar.checkout_source!
    end

    @jar_commands.add 'path', 'prints path in the shelf' do
      puts @jar.path.to_path
    end

    @jar_commands.add 'config', 'Opens jar.conf in nano' do
      @jar.open_dir!
      Compote.exec 'sudo nano jar.conf'
    end

    @jar_commands.add 'clean_dockerignore', 'Removes dangling .dockerignore file' do
      @jar.open_dir!
      @jar.clean_dockerignore!
    end

    @jar_commands.add 'run', 'Runs a source-code script' do |args|
      @jar.open_dir!
      name = shift_param! args, 'script name missing'
      if name == '-l'
        puts Dir.glob('src/.compote/scripts/*.rb').map{ File.basename _1, '.rb' }
        exit 2
      end
      $jar = @jar
      $args = args
      load "src/.compote/scripts/#{name}.rb"
    end

    @jar_commands.add 'irb', 'drops a console over the jar' do
      @jar.open_dir!
      $jar = @jar
      require 'irb'
      binding.irb
    end

    @jar_commands.add 'auto_brew', 'Sets the git-push mechanism [0,1]' do |args|
      value = shift_param! args, 'pass 0 or 1'
      @jar.open_dir!
      if value == '1'
        Compote.run 'sudo touch .brew_on_push'
        Compote.log :green, 'jar will brew on git-push'
      else
        Compote.run 'sudo rm .brew_on_push'
        Compote.log :green, 'brew on git-push is off'
      end
    end

    @jar_commands.add 'brew', 'updates the source code and runs brew script' do |args|
      @jar.open_dir!
      @jar.checkout_source!
      $jar = @jar
      load "src/.compote/scripts/brew.rb"
    end

    @jar_commands.add 'compose', 'executes a command of docker-compose' do |args|
      @jar.open_dir!
      Compote.exec @jar.compose_cmd(args.join ' ')
    end

  end
end
