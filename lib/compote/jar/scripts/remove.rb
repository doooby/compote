Dir.chdir '..'
prompt = TTY::Prompt.new
unless prompt.yes? "are you sure to irreversibly remove script #{Jar.name} ?"
  exit 1
end
Compote.run "rm -rf #{Jar.name}"
