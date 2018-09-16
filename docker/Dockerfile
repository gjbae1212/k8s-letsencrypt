FROM certbot/dns-google
# LINUX (alpine)

WORKDIR /opt/certbot

# INSTALL envsubst, curl
RUN apk update
RUN apk add gettext curl nginx

RUN mkdir -p /run/nginx
RUN mkdir -p /var/www/challenge
RUN mkdir -p /var/log/crontab

COPY ./docker /opt/certbot

RUN chmod a+x /opt/certbot/renew.sh
RUN chmod a+x /opt/certbot/entrypoint.sh

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]