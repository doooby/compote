# frozen_string_literal: true

module Compote
  class Jar
    module Directory

      def open_dir!
        jar = Compote.shelf_dir!.join @name
        unless Dir.exist? jar
          Compote.log :yellow, "jar #{@name} doesn't exist"
          exit 1
        end
        Compote.log :blue, "cd #{jar}"
        Dir.chdir jar
        jar
      end

      def prepare
        open_dir!

        # create structure
        Compote.run 'mkdir var'
        Compote.run 'mkdir tmp'
        Compote.run 'chown root:compote tmp'
        Compote.run 'chmod +t tmp'

        # create config
        Compote.run 'touch jar.conf'
        Compote.log :yellow, 'filling-in defaults'
        File.write 'jar.conf', [
          "JAR_NAME=#{name}",
          "JAR_PATH=#{Dir.pwd}",
          nil,
          'RACK_ENV=production',
          'NODE_ENV=production',
          nil
        ].join("\n")
        # config for docker compose
        Compote.run 'ln -s jar.conf .env'

        prepare_git_src
        Compote.log :green, "created jar #{name}"
      end

      def checkout_source
        unless Dir.exist? 'src'
          Compote.run 'git clone --single-branch --branch main .git src'
        end
        Compote.run <<-COMMAND
( \
  cd src && \
  git fetch origin && \
  git reset --hard origin/main && \
  git clean -fdx \
)
COMMAND
      end

      def prepare_git_src
        Compote.log :yellow, 'setting up git repository'
        Compote.run 'git init -q --bare .git'

        hook_src = LIB_PATH.join 'git_hooks/post_receive.sh'
        hook_path = '.git/hooks/post-receive'
        File.delete hook_path if File.exist? hook_path
        Compote.run "cp #{hook_src} #{hook_path}"
        Compote.run 'chown root:compote -R .git'
        Compote.run 'find .git -type d | xargs chmod 0070'
        Compote.run 'find .git -type f | xargs chmod 060'
        Compote.run "chmod 070 #{hook_path}"
      end

    end
  end
end
