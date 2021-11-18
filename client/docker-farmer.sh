#!/bin/sh

set -x
set -e
#set -o pipefail

# Dockerhub
user="bertrandlupart"
repo="pikefarm-worker"

tags=$(curl --silent --fail --location --show-error \
  "https://hub.docker.com/v2/repositories/${user}/${repo}/tags" \
  | jq --raw-output '.results[].name')

for tag in ${tags}; do
  docker pull "${user}/${repo}:${tag}"
  docker run --rm \
    --volume="$(pwd):/pikefarm" --workdir="/pikefarm" \
    --hostname="${tag}-docker" "${user}/${repo}:${tag}" "./client.sh"
done
