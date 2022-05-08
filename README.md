# compote v2
rewrite to ruby. work in progress.

## warning
this tool requires sudo access for all operations. Take it or leave it.

## install
note: requires ruby 2.7+ for root user.
sudo gem install colorize tty-prompt erb byebug

```shell
compote_dest=/opt/compote
sudo git clone https://github.com/doooby/compote.git $compote_dest
cd $compote_dest

# optionally switch branch
sudo git checkout main-v2

# set up the binary for current user
bin/install.rb ~/compote/bin/cpt
# log off and on again (added shell alias `cpt`)
# now you can run
cpt ls
```

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

--------------------------------
do `/usr/local/bin/cpt`

#!/usr/bin/env bash
set -e
cd /opt/compote
exec bin/compote "$@"

chmod +x /usr/local/bin/cpt
