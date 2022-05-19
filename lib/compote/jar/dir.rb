# frozen_string_literal: true

module Compote
  class Jar
    module Dir

      def open_dir!
        jar = Compote.shelf_dir!.join @name
        unless Dir.exist? jar
          puts "jar #{@name} doesn't exist".yellow
          exit 1
        end
        puts "cd #{jar}".blue
        Dir.chdir jar
        jar
      end

      def checkout_source!
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
        puts 'setting up git repository'
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
