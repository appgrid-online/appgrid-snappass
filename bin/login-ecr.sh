#! /usr/bin/env bash

set -o errexit
set -o pipefail

AWS_REGION=eu-central-1
REGISTRY="$AWS_ACCOUNT.dkr.ecr.$AWS_REGION.amazonaws.com"

# Log in to AWS ECR
echo "---> Logging to $REGISTRY"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REGISTRY
