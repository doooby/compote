#!/bin/bash
set -e

if [ -z "$HOST_NAMES" ]; then
  echo "HOST_NAMES is empty"
  echo "you need to set domain names in <stack_path>/stack.conf"
  exit 1
fi

config_dir=/etc/letsencrypt
certs_path=/opt/certs

function parse_domains {
  echo "$1" | tr ' ' "\n" | sed '/^ *$/d; s/.*/-d &/' | paste -sd ' '
}

function get_first_domain {
  echo "$1" | tr ' ' "\n" | sed '/^ *$/d' | sed '1q'
}

if [ $1 == "renew" ]; then
  certbot certonly --config-dir $config_dir \
      --webroot --webroot-path /var/www/acme_challenge \
      $(parse_domains "$HOST_NAMES") \
      --register-unsafely-without-email --agree-tos \
      --expand --noninteractive
fi

domain="$(get_first_domain "$HOST_NAMES")"
if [ -f $config_dir/live/$domain/privkey.pem ]; then
  cp $config_dir/live/$domain/privkey.pem $certs_path/
  cp $config_dir/live/$domain/fullchain.pem $certs_path/
fi
