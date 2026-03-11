#!/usr/bin/env bash

set -ex

# nginx in einem Docker-Container installieren
apt install -y docker.io docker-compose

mkdir -p /var/www/html
cp -vr websiteinhalt/* /var/www/html/

docker-compose up -d
