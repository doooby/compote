set -e

# $1 - stack-path
# $2 - [ "-d" destroy if exists
#      ]

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

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

echo "------ creating COMPOTE stack -> $stack_path ------"
# require confirmation
#   - about -d param
[ -d $stack_path ] && echo "hint:   rm -rf $stack_path"

echo "--- setting up privileges for $name"
if ! grep "^$name:" /etc/group > /dev/null; then
  groupadd $name
fi

echo "--- preparing stack tree at $stack_path"
mkdir $stack_path
cd $stack_path
chown root:$name .
chmod 750 .
mkdir var
mkdir tmp
chown root:$name tmp
chmod 0770 tmp

echo "--- cloning ops lib - compote"
#git -c advice.detachedHead=false clone -q --depth 1 --branch v0.3 https://github.com/doooby/compote ops
git -c advice.detachedHead=false clone -q --depth 1 https://github.com/doooby/compote ops

echo "--- configuration"
stack_conf=stack.conf
touch $stack_conf
ln -s $stack_conf .env
{
  echo "STACK_NAME=$name";
  echo "STACK_PATH=$stack_path";
  echo "RACK_ENV=production";
} >> $stack_conf

ln -s ops/lib/bin bin
ln -s bin/release _auto_release
ln -s ops/lib/deploy_stack.sh deploy

echo "--- setting up git repository"
repository=.git
git_hook=$repository/hooks/post-receive
git init -q --bare .git
rm -f $git_hook
chown root:$name -R .git
find $repository -type d | xargs chmod 0770
find $repository -type f | xargs chmod 440
ln -s ../../ops/lib/git/post-receive-hook.sh $git_hook
chgrp -h $name $git_hook

cat << HEREDOC
--- finished

------ TODO: ------
--- create a deployer:
  sudo usermod -a -G \$(basename $stack_path) \$(whoami)
--- make him sudoer
- using:   visudo
  \$(whoami)   ALL=(root)   NOPASSWD:$stack_path/deploy
--- push
--- build
  cd $stack_path
  sudo ./deploy
--- setup services
- setup db ?
- https SSL certs for nginx?
--- finalize
  sudo mv _auto_release auto_release
- now every push triggers full deploy
  (  sudo $stack_path/deploy  )
---
HEREDOC
