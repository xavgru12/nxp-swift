#!/bin/bash
#
# This script creates the yocto-ready docker image.
# The --build-arg options are used to pass data about the current user.
# Also, a tag is used for easy identification of the generated image.
#

# source the common variables
. ./env.sh

if [[ $PWD != $HOME* && $(whoami) != "root" ]]; then
    echo "Error: Current directory is outside $HOME"
    exit 1
fi

USERNAME=$(whoami)
if [[ $USERNAME == "root" ]]; then
  USERNAME=yocto
fi

docker build --tag "${DOCKER_IMAGE_TAG}" \
             --build-arg "DOCKER_WORKDIR=${DOCKER_WORKDIR}" \
             --build-arg "USER=$USERNAME" \
             --build-arg "host_uid=$(id -u)" \
             --build-arg "host_gid=$(id -g)" \
             -f Dockerfile-Ubuntu-22.04 \
             .

