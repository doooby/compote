set -e

if [ -z $HOST_NAMES ]; then
  echo "HOST_NAMES is empty"
  echo "you need to set domain names in <stack_path>/stack.conf"
  exit 1
fi

cp /opt/ops/etc/nginx/acme-challenge.conf /etc/nginx/conf.d/default.conf
nginx

function parse_domains {
  echo "$1" | tr ' ' "\n" | sed '/^ *$/d; s/.*/-d &/' | paste -sd ' '
}

certbot --nginx --register-unsafely-without-email --agree-tos \
    $(parse_domains "$HOST_NAMES")
