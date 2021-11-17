#!/bin/sh

apt-get update && apt-get upgrade -y

apt-get install -y make gcc g++ libgmp-dev wget curl nettle-dev nettle-bin \
  libmariadbd-dev

./client.sh
