set -e

# $1 - stack-path
# $2 - version - default: main

if [ -z $1 ]; then
  cat << HEREDOC
Usage:   create_stack.sh stack_path [-d]
    stack_path - for example /opt/my_stack
    -d         - destroy existing stack
HEREDOC
  exit 1
fi

stack_path=$(realpath $1)
name=$(basename $stack_path)
version=${2:-main}

# COMPOTE:   sudo bash ./create_stack.sh stack_path
#   stack_path - e.g. /opt/my-service
#
#   requires to be run as root
#
#   For next steps:
#   See HEREDOC at the end of this file
#
#   This script in human language:
#   1. ensures root user
#   2. sets up a stack path
#      (see directory structure - README.md)
#   3. provides privileges schema
#   4. installs compote library
#   5. sets up git repository
#      also installs a hook to provide git push deploy

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

echo "------ COMPOTE $stack_path ------"
# require confirmation
#   - about -d param
[ -d $stack_path ] && echo "hint:   rm -rf $stack_path"

echo "setting up privileges for $name"
if ! grep "^$name:" /etc/group > /dev/null; then
  groupadd $name
fi

echo "preparing stack tree at $stack_path"
mkdir $stack_path
cd $stack_path
chown root:$name .
chmod 750 .
mkdir var
mkdir tmp
chown root:$name tmp
chmod 0770 tmp

echo "cloning ops lib - compote"
git -c advice.detachedHead=false clone -q --depth 1 --branch $version https://github.com/doooby/compote ops
# compote check & load it? ( to colorize the output )

echo "configuration"
stack_conf=stack.conf
touch $stack_conf
ln -s $stack_conf .env
{
  echo "STACK_NAME=$name";
  echo "BOOK_PATH=$stack_path";
  echo "RACK_ENV=production";
} >> $stack_conf

ln -s ops/lib/bin bin
ln -s bin/release _auto_release
ln -s ops/lib/deploy_stack.sh deploy

echo "setting up git repository"
repository=.git
git_hook=$repository/hooks/post-receive
git init -q --bare .git
rm -f $git_hook
chown root:$name -R .git
find $repository -type d | xargs chmod 0770
find $repository -type f | xargs chmod 440
ln -s ../../ops/lib/git/post-receive-hook.sh $git_hook
chgrp -hR $name $git_hook

cat << HEREDOC

------ COMPOTE TODO: ------
create a deployer:
  \` sudo usermod -a -G \$(basename $stack_path) \$(whoami) \`
  optional: make him sudoer
    setting this allow you to invoke deployment
    sudo visudo   to add:
    $(whoami)   ALL=(root)   NOPASSWD:$stack_path/deploy
push
  this ma take a while as base images are built
config
  set your $stack_path/stack.conf
prepare services
  may want to run a first release to download the rest of dependencies
    \`  sudo bin/release  \`
  setup db ?
  https SSL certs for nginx ?
    \` sudo bash ops/lib/nginx/install_https.sh \`
toggle on git-push-release
  sudo mv _auto_release auto_release

done
HEREDOC
