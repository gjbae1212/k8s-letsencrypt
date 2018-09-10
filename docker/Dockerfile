FROM certbot/certbot:v0.27.1
# LINUX (alpine)

WORKDIR /opt/certbot

# INSTALL envsubst, curl
RUN apk update
RUN apk add gettext curl nginx

RUN mkdir -p /run/nginx
RUN mkdir -p /var/www/challenge
RUN mkdir -p /var/log/crontab

COPY ./docker /opt/certbot
COPY ./nginx/default.conf /opt/certbot

RUN chmod a+x /opt/certbot/renew.sh
RUN chmod a+x /opt/certbot/entrypoint.sh

# ENV
ENV WWW /var/www/challenge

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]