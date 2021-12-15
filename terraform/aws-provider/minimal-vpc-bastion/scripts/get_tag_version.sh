#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
GIT_COMMIT=$(git rev-parse --short HEAD)
REV_COUNT=$(git log --oneline | wc -l | tr -d ' ')

VERSION=$GIT_BRANCH"-"$GIT_COMMIT"-rev-"$REV_COUNT

jq -n --arg version "$VERSION" '{"version":$version}'
