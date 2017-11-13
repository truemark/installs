#!/usr/bin/env bash

# This script will install docker-ce.
# https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce

set -uex

apt-get update

apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

apt-key fingerprint 0EBFCD88

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update

apt-get install docker-ce

apt-mark hold docker-ce
