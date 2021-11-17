#!/bin/sh

apt-get update && apt-get upgrade -y

apt-get install -y make gcc g++ m4 libgmp-dev wget curl nettle-dev nettle-bin \
  libmariadbd-dev

./client.sh
