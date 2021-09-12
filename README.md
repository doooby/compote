# compote
docker-compose based stack ops for simple git push deployment of dockerized application

## create stack
read HOW_TO to familiarize yourself with the process before running the create_stack.sh script.

then:
```shell script
version=master
curl -o /tmp/compote https://raw.githubusercontent.com/doooby/compote/$version/lib/create_stack.sh
less /tmp/compote # read before execute
stack=/opt/my-stack
bash /tmp/compote $stack $version
```

and follow on more instructions
(you can `cat $stack/HOW_TO`)

## stack structure
```
/stack-dir/
    stack.conf - stack variables
    .dockerignore - virtual created on demand
    .env - symlink to stack.conf
    .git/ - remotely accessible repository
    deploy - link to after push script
    release - compote recipes for building & deploying new release
            - rename release -> _release to disable that (init state)
    src/ - git working dir
    ops/ - compote source files
    bin/ - symlink to ops/lib/bin
    var/ - stack data
    tmp/ - public dir
```
