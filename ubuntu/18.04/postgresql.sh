#!/usr/bin/env bash

# To execute this script run the following as root
# bash <(curl http://installs.truemark.io/ubuntu/18.04/truemark.sh)
set -uex

wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" | sudo tee /etc/apt/sources.list.d/postgresql.list
apt-get update
apt-get install -y postgresql-10
