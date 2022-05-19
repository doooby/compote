file = '.brew_on_push'
File.delete file if File.exist? file
puts 'brew on git push is off'.yellow
