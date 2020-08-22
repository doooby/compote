FROM nginx:base

COPY ops/etc/nginx/release/entrypoint.sh entrypoint
COPY ops/lib/nginx/update_certificate.sh update_certificate
COPY ops/etc/nginx/app.conf /etc/nginx/conf.d/default.conf

COPY src/public /var/www/app
COPY var/frontend /var/www/app

RUN chmod +x entrypoint && \
    chmod +x update_certificate && \
    mkdir certs

ENTRYPOINT [ "./entrypoint" ]
