# frozen_string_literal: true

module Compote
  class Jar

      def dockerignore_path
       @dockerignore_path ||= path.join(IGNORE_FILE)
      end
      IGNORE_FILE = '.dockerignore'

    def clean_dockerignore!
      Compote.run "sudo rm -f #{dockerignore_path}"
    end

      def with_dockerignore content
        if File.exist? dockerignore_path
            Compote.log :red, "#{dockerignore_path} is present."
            Compote.log :white, 'either another build is in progress' +
              ' or the previous one failed.'
            exit 1
        end
        Compote.run "echo '*\n#{content}' | sudo tee #{dockerignore_path} > /dev/null"
        yield
        clean_dockerignore!
      end

      def compose_cmd cmd
        <<-COMMAND.strip
sudo docker compose \\
  -f src/.compote/docker-compose.yml \\
  --env-file .env \\
  -p jar_#{name} \\
  #{cmd}
COMMAND
      end

  end
end
