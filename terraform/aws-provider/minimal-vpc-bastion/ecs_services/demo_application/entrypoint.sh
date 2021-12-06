#!/bin/sh
export HOST=$(curl -f --retry 3 --connect-timeout 3 -s 169.254.169.254/latest/meta-data/local-hostname)
export INSTANCE_ID=$(curl -f --retry 3 --connect-timeout 3 -s 169.254.169.254/latest/meta-data/instance-id)
export PUBLIC_IP=$(curl -f --retry 3 --connect-timeout 3 -s 169.254.169.254/latest/meta-data/public-ipv4)
export ECS_METADATA=$(curl -f --retry 3 --connect-timeout 3 -s $ECS_CONTAINER_METADATA_URI_V4)

exec "$@"
