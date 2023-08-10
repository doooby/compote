# frozen_string_literal: true

module Compote
  class Jar

      def checkout_source!
        unless Dir.exist? 'src'
          Compote.run 'sudo git clone --single-branch --branch main .git src'
        end
        Compote.run <<-CMD.strip
sudo bash -c "( \\
  cd src && \\
  git fetch origin && \\
  git reset --hard origin/main && \\
  git clean -fdx \\
)"
CMD
      end

      def initialize_repo!
        hook_src = LIB_PATH.join 'git_hooks/post_receive.sh'
        Compote.log :yellow, 'setting up git repository'
        Compote.run <<-CMD.strip
sudo bash -c "\\
    git init -q --bare .git && \\
    rm .git/hooks/* && \\
    cp #{hook_src} .git/hooks/post-receive && \\
    chown root:compote -R .git && \\
    find .git -type d | xargs chmod 0070 && \\
    find .git -type f | xargs chmod 060 && \\
    chmod 070 .git/hooks/post-receive
"
        CMD
      end

  end
end
