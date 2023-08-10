# frozen_string_literal: true

module Compote
  class Jar

    def path
        @path ||= Compote.shelf_dir!.join(@name)
    end

    def exists?
        Dir.exist? path
    end

  def open_dir!
    unless exists?
      Compote.log :yellow, "jar #{@name} doesn't exist"
      exit 1
    end
    Compote.log :blue, "cd #{path}"
    Dir.chdir path
    path
  end

  def initialize_jar!
    open_dir!

    # create structure
    Compote.run <<-CMD.strip
sudo bash -c "\\
    mkdir var && chmod 700 var && \\
    mkdir tmp && chown root:compote tmp && chmod 770 tmp && \\
    touch jar.conf && chmod 640 jar.conf
"
    CMD

    # create config
    Compote.log :yellow, 'filling-in defaults'
    system 'sudo chmod o+w jar.conf'
    File.write 'jar.conf', [
      "JAR_NAME=#{name}",
      "JAR_PATH=#{Dir.pwd}",
      nil,
      'RACK_ENV=production',
      'NODE_ENV=production',
      nil
    ].join("\n")
    system 'sudo chmod o-w jar.conf'
    Compote.run 'sudo ln -s jar.conf .env' # config for docker compose

    initialize_repo!
    Compote.log :green, "created jar #{name}"
  end

  end
end
