#!/bin/sh

set -x
set -e
#set -o pipefail

# Dockerhub
user="bertrandlupart"
repo="pikefarm-worker"


# xenofarm user in pikefarm-worker containers
uid=817
gid=817

echo "xenofarm user in container images is ${uid}:${gid}"
echo "You may need to allow it to write at the root of this dir (PID file) :"
echo "  chgrp ${gid} ."
echo "  chmod g+w ."
echo "You may also allow it to download and compile in the project dirs"
echo "if your Docker host run Pikefarm project :"
echo "  chgrp -R ${gid} pike-* project_*"
echo "  chmod -R g+w pike-* project_*"
echo "These ugly tricks should be made obsolete by smarter improvements "
echo "in client.sh"



tags=$(curl --silent --fail --location --show-error \
  "https://hub.docker.com/v2/repositories/${user}/${repo}/tags" \
  | jq --raw-output '.results[].name')

for tag in ${tags}; do
  docker pull "${user}/${repo}:${tag}"
  docker run --rm \
    --volume="$(pwd):/pikefarm" --workdir="/pikefarm" \
    --hostname="${tag}-docker" "${user}/${repo}:${tag}" "./client.sh"
done
