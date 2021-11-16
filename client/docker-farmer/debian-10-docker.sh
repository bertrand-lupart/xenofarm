#!/bin/sh

apt-get update && apt-get upgrade -y

apt-get install -y make gcc g++ libgmp-dev wget nettle-dev nettle-bin

./client.sh
