file = '.brew_on_push'
File.write file, '' unless File.exist? file
puts 'jar will brew on git push'.green
