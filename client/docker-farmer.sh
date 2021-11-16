#!/bin/sh -x

DEBIAN="9 10 11 sid"

for d in ${DEBIAN}; do
  host=debian-${d}-docker
  docker run -it --rm \
    -v "$(pwd):/pikefarm" -w /pikefarm \
    -h "${host}" debian:${d} docker-farmer/${host}.sh
done
