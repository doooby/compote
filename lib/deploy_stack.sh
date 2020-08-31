set -e

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

stack_path=$(pwd)
working_dir=$stack_path/src

if [ ! -d $working_dir ]; then
  echo "detected initial state, cloning working directory"
  git clone --single-branch --branch master .git $working_dir
  echo "running recipe src/.compote/init.sh"
  bin/initialize

else
  cd $working_dir
  git fetch origin
  git reset --hard origin/master
  git clean -fdx
  cd $stack_path
  echo

fi

[ -f ./auto_release ] && time -p ./auto_release
