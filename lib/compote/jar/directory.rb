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

    end
  end
end
