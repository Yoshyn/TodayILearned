#!/bin/sh
export HOST=$(curl --retry 3 --connect-timeout 3 -s 169.254.169.254/latest/meta-data/local-hostname)
export INSTANCE_ID=$(curl --retry 3 --connect-timeout 3 -s 169.254.169.254/latest/meta-data/instance-id)
export PUBLIC_IP=$(curl --retry 3 --connect-timeout 3 -s 169.254.169.254/latest/meta-data/public-ipv4)
export ECS_METADATA=$(curl --retry 3 --connect-timeout 3 -s http://localhost:51678/v1/metadata) # FIXME: DO NOT WORK

exec "$@"
