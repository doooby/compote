#!/bin/bash
set -e

./update_certificate

### Send certbot Emission/Renewal to background
$(while :; do ./update_certificate renew; sleep "12h"; done;) &

### Check for changes in the certificate (i.e renewals or first start) and send this process to background
$(while inotifywait -e close_write /opt/certs; do nginx -s reload; done) &

### Start nginx with daemon off as our main pid
nginx -g "daemon off;"
