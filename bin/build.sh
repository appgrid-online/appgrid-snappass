#! /usr/bin/env bash

# Example usages:
# To build docker image
# ./build.sh
# To build docker image and push to ECR
# ./build.sh --push

set -o errexit
set -o pipefail

push=false

if [ "$#" -eq 1 ] && [ "$1" = "--push" ]; then
    push=true
elif [ "$#" -gt 1 ]; then
    echo "Too many arguments. Only one argument or none (for no push) expected."
    exit 1
fi

echo "---> Performing docker image build..."

BRANCH=${GITHUB_HEAD_REF:-$(git symbolic-ref --short -q HEAD)}
echo " --> BRANCH=$BRANCH"

REV_SHORT=${GITHUB_HEAD_SHA:-$(git rev-parse --short=8 HEAD)}
echo " --> REV_SHORT=$REV_SHORT"

DATETIME=${DATETIME:-$(git log -1 --format=%cd --date=format:'%Y%m%d_%H%M%S')}
echo " --> DATETIME=$DATETIME"

REGISTRY="175081405432.dkr.ecr.eu-central-1.amazonaws.com"
echo " --> REGISTRY=$REGISTRY"

REPOSITORY=appgrid-snappass
echo " --> REPOSITORY=$REPOSITORY"


echo "---> Building docker image..."

docker buildx build \
    --platform=linux/amd64 . \
    -f Dockerfile \
    --load \
    --build-arg SOURCE_VERSION=$DATETIME \
    --tag $REPOSITORY \
    --tag $REGISTRY/$REPOSITORY:$BRANCH \
    --tag $REGISTRY/$REPOSITORY:$REV_SHORT \
    --tag $REGISTRY/$REPOSITORY:$DATETIME

if $push_flag; then
    echo "---> Performing docker image push..."
    docker push $REGISTRY/$REPOSITORY -a
fi

echo "---> Done."
