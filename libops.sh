export stack_path=$(pwd)
export stack_name=$(basename $stack_path)

function libops_aquire_dockerignore_lock {
  libops_assert_stack_path

  lock_file=$(realpath .dockerignore)
  [ -f $lock_file ] && libops_fail_with << HEREDOC
Could not acquire ops/docker lock - .dockerignore alread exists
pwd: $stack_path
HEREDOC

  touch $lock_file
  echo $lock_file
}

function libops_assert_stack_path {
  [ -f stack.conf ] && return 0
  libops_fail_with << HEREDOC
Wrong working directory - could not locate stack.conf
pwd: $stack_path
HEREDOC
}

function libops_print {
  case $1 in
    -p)
      ;&
    --paragraph)
      msg="    $2"
      ;;

    *)
      msg="> $1"
      ;;

  esac
  echo -e "\033[36m[LIBOPS] [$(date +"%y%m%d %T")]\033[0m $msg"
}

function libops_fail_with {
  echo -e "\033[31m[LIBOPS] FAIL:\033[0m" >> /dev/stderr
  cat /dev/stdin >> /dev/stderr
  exit 1
}

function libops_docker_run {
  libops_assert_stack_path

  # $1 = image
  # $2 = docker opts
  # $3 = command
  cmd="docker run --rm $2 --env-file $stack_path/.env $1 $3"
  libops_print "exec: \033[35m${cmd}\033[0m"
  $cmd
}

function libops_script_run {
  libops_assert_stack_path

  # $1 = script name
  file_path=$stack_path/src/.compote/$1
  if [ ! -f $file_path ]; then
    libops_fail_with << HEREDOC
script .compote/$1 is not present in source code
HEREDOC
  fi

  source $file_path
}
