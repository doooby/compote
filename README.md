# Compote
Docker-based tool to run services.

The **aim** of this is not to apply the best standards or be super performant but rather a **simple** solution for **git-push deployment** of containers on **own servers**.

Each project is represented as a **compote jar** - a dedicated directory that holds configuration and git source code, optionally cached libraries, data to be persisted, etc.

## Requirements

##### system
GNU/Linux, bash. Developed on Ubuntu server 22.04.

##### sudo
This tool expects that you access the server as a non-root user with password-less sudo provided.

##### ruby
System-wide installation with the following gems required. Developed with 3.0 version.
```shell
sudo apt install ruby
sudo gem install colorize tty-prompt
```

## Install

download compote:
```shell
sudo git clone https://github.com/doooby/compote.git /opt/compote
```
```shell
# install the entry point for the user
/opt/compote/bin/user_install.rb ~/.compote/cli
```

log off and on again
```shell
# now you can run compote using alias
compote ls
```
