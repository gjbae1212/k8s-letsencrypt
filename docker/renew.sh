#!/bin/bash

cd /opt/certbot

certbot renew --quiet --no-self-upgrade >> /var/log/letsencrypt/letsencrypt.log

CERTPATH=/etc/letsencrypt/live/$(echo $DOMAIN | cut -f1 -d',')
echo "CERT : ${CERTPATH}"

echo "PUBLIC"
export TLS_CRT=$(cat ${CERTPATH}/fullchain.pem | base64 | tr -d '\n')
echo TLS_CRT

echo "PRIVATE"
export TLS_KEY=$(cat ${CERTPATH}/privkey.pem | base64 | tr -d '\n')
echo TLS_KEY

# kubernetes namespace
export NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
echo "NAMESPACE : ${NAMESPACE}"

# update secret
envsubst < secert-template.json > secret.json
cat secret.json

# update secret
curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
-H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
-k -v -XPATCH  -H "Accept: application/json, */*" -H "Content-Type: application/strategic-merge-patch+json" \
-d @secret.json https://kubernetes.default/api/v1/namespaces/${NAMESPACE}/secrets/${SECRET} >> /var/log/letsencrypt/letsencrypt.log