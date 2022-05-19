# Compote
Docker-based tool to run services.

The **aim** of this is not to apply the best standards or be super performant but rather a **simple** solution for **git-push deployment** of containers on **own servers**.

Each service is represented as a **compote jar** - a dedicated directory that holds configuration and git source code, optionally cached libraries, data to be persisted, etc.

## Requirements

##### system
GNU/Linux, bash. Developed on Ubuntu server 22.04.

##### sudo
This tool expects that you access the server as a non-root user with password-less sudo provided.

##### ruby
System-wide installation required. Developed with 3.0 version.

##### docker & docker compose
Root access is enough as compote-cli is always called with sudo.

## Install

```shell
sudo gem install colorize tty-prompt
# for dev & testing
sudo gem install byebug colorize tty-prompt
```

download compote:
```shell
sudo mkdir /opt/compote && sudo chown `whoami` /opt/compote
git clone https://github.com/doooby/compote.git /opt/compote
# optionally switch branch
(cd /opt/compote && git checkout main-v2)
# install the entry point for the user
/opt/compote/bin/user_install.rb ~/.compote/cli
```

log off and on again
```shell
# now you can run compote using alias
compote ls
```
