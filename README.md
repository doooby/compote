# Compote
Docker-based tool to run services.

The **aim** of this is not to apply the best standards or be super performant but rather a **simple** solution for **git-push deployment** of containers on **own servers**.

Each project is represented as a **"compote jar"** - a dedicated directory that holds configuration and git source code, optionally cached libraries, data to be persisted, etc.

You define your own scripts inside the project, which do all the necessary work before a release docker image can be built and the container run. These scripts are run as the deployer user.

## Requirements

##### system
GNU/Linux, bash. Developed on Ubuntu server 22.04.

##### sudo
This tool expects that you access the server as a non-root user with password-less sudo provided.

##### docker
this tool is docker-based, please head to (https://docs.docker.com/engine/install/)[docker install docs] to install it.

##### ruby
System-wide installation with the following gems required. Developed with 3.0 version.
```shell
sudo apt install ruby
sudo gem install colorize tty-prompt dotenv
```

## Install
ssh to the server and download compote:
```shell
sudo git clone https://github.com/doooby/compote.git /opt/compote
```

As the deployer user, that has sudo access:
```shell
/opt/compote/bin/user_install.rb
```

```shell
# log off and on again
# now you can run compote using alias
compote ls
```

## Use
Before creating new compote jar on the server, you need have some config files in your repository. see next section for details.

This example is for Ruby on Rails application.
- note it will take considerable more time to run for the first time commands like `update` and `brew`. It will download docker images and in this case also ruby gems.
- `run build_base` creates a base image that is neccessary to:
  - build the release one
  - install ruby gems
  - build assets
- `brew` will fail for the first time on missing database. Just import/restore using postgresql tools or create new one. Then run the `brew` command again.
- `compose` is there to simply run one-off app instances to do stuff like database imports, rake tasks, etc.
```shell
compote new app
# which print as last line: `git repository path: /var/compote_shelf/app/.git`
# add this as a remote and `git push` to it

jar app update # updates the source code internaly
jar app run build_base # runs .compote/scripts/build_base.rb
jar app brew # deploy, i.e. it runs .compote/scripts/brew.rb

# for automatic deploys via git "post-receive" hook
jar app auto_brew 1

# spin up app container to check
jar app compose run --rm app bash
```

### compote configuration for a repository
Create `./.compote` directory.
```yaml
# .compote/docker-compose.yml
services:

  app:
    image: jar--${JAR_NAME}:release
    env_file:
      - ${JAR_PATH}/.env
    command: bash -c "rm -f tmp/pids/server.pid && bin/rails s -p 3000"
    restart: unless-stopped
    depends_on:
      - pg
    ports:
      - ${APP_SERVICE_PORT}:3000
    volumes:
      - ${JAR_PATH}/var/ruby_bundle:/usr/local/bundle
      - ${JAR_PATH}/var/log:/app/log

  pg:
    image: postgres:17
    environment:
      POSTGRES_HOST_AUTH_METHOD: trust
    restart: unless-stopped
    shm_size: 100mb
    volumes:
      - ${JAR_PATH}/var/pg_data:/var/lib/postgresql/data
```
```Dockerfile
# .compote/app.base.Dockerfile
FROM ruby:3.3.5

WORKDIR /app

RUN \
    apt-get -qq update && \
    apt-get -qq -y install postgresql-client-17
```
```Dockerfile
# app.release.Dockerfile
ARG JAR_NAME
FROM jar--${JAR_NAME}:base

COPY src .

COPY var/assets ./public/assets
```
```rb
# .compote/scripts/build_base.rb
$jar.with_dockerignore do
  Compote.run <<-CMD
sudo docker build \\
  -f src/.compote/app.base.Dockerfile \\
  -t jar--#{$jar.name}:base \\
  .
CMD
end
```
```rb
# .compote/scripts/brew.rb
Compote.log :yellow, '===== installing gems'
Compote.run <<-CMD
sudo docker run --rm \\
  -v ./src:/app \\
  -v ./var/ruby_bundle:/usr/local/bundle \\
  jar--#{$jar.name}:base \\
  bash -c " \\
bundle config set --local without 'development test' && \\
bundle install \\
"
CMD

Compote.log :yellow, '===== building assets'
Compote.run <<-CMD
sudo docker run --rm \\
  -v ./src:/app \\
  -v ./var/ruby_bundle:/usr/local/bundle \\
  -v ./var/assets:/app/public/assets \\
  jar--#{$jar.name}:base \\
  rails assets:precompile
CMD

Compote.log :yellow, '===== building docker image'
dockerignore = <<-FILE
!src
!var/ruby_bundle
!var/assets
FILE
$jar.with_dockerignore dockerignore do
  Compote.run <<-CMD
sudo docker build \\
  -f src/.compote/app.release.Dockerfile \\
  -t jar--#{$jar.name}:release \\
  --build-arg JAR_NAME=#{$jar.name} \\
  .
CMD
end

Compote.log :yellow, "===== DANGER ZONE =====\n(point of no return)"

Compote.run $jar.compose_cmd('run --rm app rails db:migrate')

Compote.log :yellow, '===== restarting container'
Compote.run $jar.compose_cmd('up -d')
```
