# Compote
Docker-based tool to run services.

The **aim** of this is not to apply the best standards or be super performant but rather a **simple** solution for **git-push deployment** of containers on **own servers**.

Each service is represented as a **"compote jar"** - a dedicated directory that holds configuration and git source code, optionally cached libraries, data to be persisted, etc.

You define your own scripts inside the project, that does all necessary work before a release docker image can be built and containers run. These scripts are run as the deployer user and give you simple access to compote tasks to run containers and access the jar's directory. The compote cli runner is elevated to root to be able to do stuff.

## Requirements

##### system
GNU/Linux, bash. Developed on Ubuntu server 22.04.

##### sudo
This tool expects that you access the server as a non-root user with password-less sudo provided.

##### ruby
System-wide installation with the following gems required. Developed with 3.0 version.
```shell
sudo gem install colorize tty-prompt dotenv
```

##### docker & docker compose
Root access is enough as compote-cli is always called with sudo.

## Install

ssh to the server and download compote:
```shell
sudo git clone https://github.com/doooby/compote.git /opt/compote
# optionally switch branch
(cd /opt/compote && sudo git checkout main-v2)
```

```shell
# as the deployer user
/opt/compote/bin/user_install.rb
# log off and on again
# now you can run compote using alias
compote ls
```
