#!/bin/sh

set -x
set -e

# Dockerhub
USER="bertrandlupart"
REPO="pikefarm-worker"
DHUB=${USER}/${REPO}

TAGS=$(curl -s https://hub.docker.com/v2/repositories/${USER}/${REPO}/tags |jq -r '.results[].name')

for d in ${TAGS}; do
  host=${d}-docker
  docker run -it --rm \
    -v "$(pwd):/pikefarm" -w /pikefarm \
    -h "${host}" ${DHUB}:${d} ./client.sh
done
