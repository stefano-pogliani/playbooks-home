#! /bin/bash
set -e

# AuthGateway runs as a non-privileged user while cetbot stores certificates in a root-only path.
# This script, run as a certbot deploy hook, copies the certificates to an
# accessible location and sets their permissions before restarting the authgateway service.
cp '/etc/letsencrypt/live/home.spogliani.net/fullchain.pem' '/opt/authgateway/certs/fullchain.pem'
cp '/etc/letsencrypt/live/home.spogliani.net/privkey.pem' '/opt/authgateway/certs/privkey.pem'
chown -R 'authgateway:authgateway' '/opt/authgateway/certs'

systemctl restart authgateway
