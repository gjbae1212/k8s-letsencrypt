#!/bin/bash

certbot renew --quiet --no-self-upgrade

NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)

# update secret
curl -v --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
-H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
-k -v -XPATCH  -H "Accept: application/json, */*" -H "Content-Type: application/strategic-merge-patch+json" \
-d @secret.json https://kubernetes.default/api/v1/namespaces/${NAMESPACE}/secrets/${SECRET}