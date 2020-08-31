# compote
docker-compose based stack ops

## create stack
read HOW_TO to familiarize yourself with the process before running the create_stack.sh script.

then:
```shell script
#curl -o /tmp/compote https://raw.githubusercontent.com/doooby/compote/v0.3.0/lib/create_stack.sh
curl -o /tmp/compote https://raw.githubusercontent.com/doooby/compote/master/lib/create_stack.sh
less /tmp/compote # read before execute
bash /tmp/compote "/opt/my-stack-name"
```

## stack structure
```
/stack-dir/
    stack.conf - stack variables
    .dockerignore - virtual created on demand
    .env - symlink to stack.conf
    .git/ - remote repository
    src/ - git working directory
    ops/ - compote files
    bin/ - symlink for ops/lib/bin
    var/ - stack data
    tmp/ - for live containers mounting
```
