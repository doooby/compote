FROM nginx:stable

WORKDIR /opt

RUN \
    apt-get -qq update && \
    apt-get -qq -y install certbot python-certbot-nginx inotify-tools && \
    \
    mkdir -p /var/www/acme_challenge
