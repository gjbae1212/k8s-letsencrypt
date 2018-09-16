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
   export GCP_PROJECT=$1 # gcp project id
   export GCP_JWT_PATH=$2 # gcp jwt path
   export REPOSITORY=$3 # repository
   export EMAIL=$4 # email
   export DOMAIN=$5 # domain
   export NAMESPACE=$6 # kubernetes namespace
   export SECRET=$7 # tls secret
   export BASE64_GCP_PROJECT=`echo $GCP_PROJECT | base64`
   export BASE64_GCP_JWT=`cat $GCP_JWT_PATH | base64`

   if [[ -z $GCP_PROJECT || -z $GCP_JWT_PATH || -z $REPOSITORY || -z $EMAIL || -z $DOMAIN || -z $NAMESPACE || -z $SECRET ]]; then
	echo "REQUIRE!! GCP_PROJECT, GCP_JWT_PATH, REPOSITORY EMAIL, DOMAINS, NAMESPACE, SECRET"
	exit 1
   fi

   # [step1] create namespace
   kubectl create namespace ${NAMESPACE} || true

   # [step2] service account 설정
   envsubst < $CURRENT/gcp/service-account.yaml | kubectl apply -f -

   # [step3] my account will bind to cluster-admin-role
   kubectl create clusterrolebinding cluster-admin-binding \
   --clusterrole cluster-admin --user $(gcloud config get-value account) || true

   # [step4] make secret role
   envsubst < $CURRENT/k8s/k8s-role.yaml | kubectl apply -f -

   # [step5] bind to secret role
   envsubst < $CURRENT/k8s/k8s-rolebinding.yaml | kubectl apply -f -

   # [step6] make empty tls secret
   envsubst < $CURRENT/k8s/k8s-secret.yaml | kubectl apply -f -

   # [step7] build docker image
   build $REPOSITORY

   # [step8] deploy
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