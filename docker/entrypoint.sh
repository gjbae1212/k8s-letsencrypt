#!/bin/bash

if [[ -z $EMAIL || -z $DOMAIN || -z $SECRET ]]; then
	echo "EMAIL, DOMAIN, SECRET"
	env
	exit 1
fi

certbot certonly -n --agree-tos --email ${EMAIL} --no-self-upgrade -d "*.${DOMAIN}" -d "${DOMAIN}" \
--dns-google --dns-google-credentials /tmp/gcp/GCP_JWT  \
--dns-google-propagation-seconds 120 \
--work-dir /var/lib/letsencrypt  --logs-dir /var/log/letsencrypt --config-dir /etc/letsencrypt

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

curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
-H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
-k -v -XPATCH  -H "Accept: application/json, */*" -H "Content-Type: application/strategic-merge-patch+json" \
-d @secret.json https://kubernetes.default/api/v1/namespaces/${NAMESPACE}/secrets/${SECRET}

# crontab and renewal
echo "* * * */1 * /bin/sh /opt/certbot/renew.sh" >> /etc/crontabs/root
crond -bS -L /var/log/crontab/log

tail -f /var/log/letsencrypt/letsencrypt.log