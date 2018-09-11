#!/bin/bash

set -e -o pipefail

cd `dirname $0`
CURRENT=`pwd`

function build
{
   docker build --no-cache -t $1 -f docker/Dockerfile .
   docker tag $1 $1
   docker push $1
}

function certbot
{
   export REPOSITORY=$1
   export EMAIL=$2
   export DOMAIN=$3
   export NAMESPACE=$4
   export SECRET=$5
   export STATIC_IP_NAME=$6

   if [[ -z $REPOSITORY || -z $EMAIL || -z $DOMAIN || -z $NAMESPACE || -z $SECRET || -z $STATIC_IP_NAME ]]; then
	echo "REQUIRE!! REPOSITORY EMAIL, DOMAIN, NAMESPACE, SECRET, STATIC_IP_NAME, APP_SERVICE"
	exit 1
   fi

   envsubst < $CURRENT/k8s/k8s-role.yaml | kubectl apply -f -

   envsubst < $CURRENT/k8s/k8s-rolebinding.yaml | kubectl apply -f -

   envsubst < $CURRENT/k8s/k8s-secret.yaml | kubectl apply -f -

   envsubst < $CURRENT/k8s/k8s-service.yaml | kubectl apply -f -

   envsubst < $CURRENT/k8s/k8s-init-ingress.yaml | kubectl apply -f -

   build $REPOSITORY

   sleep 200 # wait 200 seconds

   envsubst < $CURRENT/k8s/k8s-deployment.yaml | kubectl apply -f -
}

function update_app
{
   export DOMAIN=$1
   export NAMESPACE=$2
   export SECRET=$3
   export STATIC_IP_NAME=$4
   export APP_SERVICE=$5

   if [[ -z $DOMAIN || -z $NAMESPACE || -z $SECRET || -z $STATIC_IP_NAME || -z $APP_SERVICE ]]; then
	echo "REQUIRE!! DOMAIN, NAMESPACE, SECRET, STATIC_IP_NAME, APP_SERVICE"
	exit 1
   fi

   envsubst < $CURRENT/k8s/k8s-complete-ingress.yaml | kubectl apply -f -
}


CMD=$1
shift
$CMD $*