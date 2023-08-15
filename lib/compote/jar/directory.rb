# frozen_string_literal: true

module Compote
  class Jar

    def path
        @path ||= Compote.shelf_dir!.join(name)
    end

    def exists?
        Dir.exist? path
    end

  def open_dir!
    unless exists?
      Compote.log :yellow, "jar #{name} doesn't exist"
      exit 1
    end
    Compote.log :blue, "cd #{path}"
    Dir.chdir path
    path
  end

  def initialize_jar!
    open_dir!

    # create structure
    Compote.run <<-CMD
sudo bash -c "\\
    mkdir var && chmod 700 var && \\
    mkdir tmp && chown root:compote tmp && chmod 770 tmp && \\
    touch jar.conf && chown root:compote jar.conf && chmod 640 jar.conf
"
    CMD

    # create config
    Compote.log :yellow, 'filling-in defaults'
    temp_conf = Tempfile.new('jar.conf')
    temp_conf.write [
      "JAR_NAME=#{name}",
      "JAR_PATH=#{Dir.pwd}",
      nil,
      'RACK_ENV=production',
      'NODE_ENV=production',
      nil
    ].join("\n")
    temp_conf.flush
    system "sudo bash -c 'cat #{temp_conf.path} > jar.conf'"

    initialize_repo!
    Compote.log :green, "created jar #{name}"
  end

  end
end
