#!/usr/bin/env bash

set -o errexit
set -o nounset

if [[ -z "$1" && ! -f "$1" ]]; then
  echo "[error] need k8s resource definition file from kustomize"
  exit 1
fi

RESOURCE_DEF=$1
 
# default values
export DRONE_DEPLOY_TO=${DRONE_DEPLOY_TO:?'[error] Please specify which cluster to deploy to.'}
export KUBE_NAMESPACE=${KUBE_NAMESPACE:=cdp-dev}
export KUBE_CERTIFICATE_AUTHORITY=https://raw.githubusercontent.com/UKHomeOffice/acp-ca/master/${DRONE_DEPLOY_TO}.crt

export NAME="docker-tinkerpop-graphdb-config"

case ${DRONE_DEPLOY_TO} in
  'acp-notprod')
    export KUBE_SERVER="https://kube-api-notprod.notprod.acp.homeoffice.gov.uk"
    # NOTE: the KUBE_TOKEN_ACP_NOTPROD is stored as a drone secret
    export KUBE_TOKEN=${KUBE_TOKEN_ACP_NOTPROD}
    # case ${KUBE_NAMESPACE} in
    #     'cdp-dev')
    #     ;;
    # esac
    ;;
esac

echo "--- kube api url: ${KUBE_SERVER}"
# echo "--- namespace: ${KUBE_NAMESPACE}"

echo "--- deploying graphdb application"
if ! kd -f $RESOURCE_DEF ; then
  echo "[error] failed to deploy graphdb application"
  exit 1
fi
