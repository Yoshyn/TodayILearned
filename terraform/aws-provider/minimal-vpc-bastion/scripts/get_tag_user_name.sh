#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

eval $(jq -r '@sh "export AWS_PROFILE=\(.aws_profile)"')
if [[ -z "${AWS_PROFILE}" ]]; then export AWS_PROFILE=default; fi

USERNAME=$(aws sts get-caller-identity --profile $AWS_PROFILE --output text --query 'Arn' | rev | cut -d '/' -f 1 | rev)

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted and escaped to produce a valid JSON string.
jq -n --arg username "$USERNAME" '{"username":$username}'
