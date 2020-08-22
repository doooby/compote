set -e

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

source ops/libops.sh

data_path=$stack_path/var/letsencrypt
if [ -d $data_path ]; then
  read -p "Looks like you are running this again. Are you sure to replace current SSL certificate? (Y/n):" decision
  [ "$decision" != "Y" ] && exit 0
  rm -rf $data_path
fi

libops_print "installing SSL certificates" , "title"
mkdir -p $data_path
libops_docker_run nginx:base \
  "-p 80:80 -v $data_path:/etc/letsencrypt -v $stack_path/ops:/opt/ops" \
  "bash /opt/ops/lib/nginx/create_ssl_cert.sh"
