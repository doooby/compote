Dir.chdir '..'
prompt = TTY::Prompt.new
unless prompt.yes? "are you sure to irreversibly remove script #{JAR.name} ?"
  exit 1
end
Compote.run "rm -rf #{JAR.name}"
