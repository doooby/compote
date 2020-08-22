set -e

if [ -z $1 ]; then
  echo "Usage:   create_stack.sh stack_path"
  echo "    stack_path - for example /opt/my_stack"
  exit 1
fi

stack_path=$(realpath $1)
name=$(basename $stack_path)

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

# create group
groupadd $name

echo "--- preparing stack path at $stack_path"
# create stack path
mkdir $stack_path
cd $stack_path
chown root:$name .
chmod 750 .

stack_conf=stack.conf
touch $stack_conf
ln -s $stack_conf .env
echo "STACK_NAME=$name" >> $stack_conf
echo "STACK_PATH=$stack_path" >> $stack_conf
echo "RAILS_ENV=production" >> $stack_conf

mkdir var
mkdir tmp
chown root:$name tmp
chmod 0770 tmp

git clone --depth 1 --branch v0.1 https://github.com/doooby/compote ops
ln -s ops/bin bin
ln -s bin/release _deploy

echo "--- seting up git repository"
# create git repo
repository=.git
git init --bare .git
chown root:$name -R .git
find $repository -type d | xargs chmod 0770
find $repository -type f | xargs chmod 440

echo "--- installing git hooks"
# write build hook
git_hook=$repository/hooks/post-receive
rm -f $git_hook
ln -s ops/lib/git/post-receive-hook.sh $git_hook
chgrp -h $name $git_hook
chmod -h 550 $git_hook

echo "--- finished"
