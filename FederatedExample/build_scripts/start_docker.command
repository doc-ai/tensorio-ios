#!/bin/sh

FLEA_IMAGE=docai/tensorio-flea

# Set terminal title

echo -en "\\033]0;TensorIO Flea Docker\\a"
clear

# kill any currently running flea container

if [ "$(docker ps -q --filter ancestor=$FLEA_IMAGE)" ]; then
  docker stop $(docker ps -q --filter ancestor=$FLEA_IMAGE )
fi

# tensorio-models directory

if [[ -z "${TENSORIO_MODELS_DIR}" ]]; then
  TENSORIO_MODELS_DIR=~/repos/tensorio-models/
fi
cd $TENSORIO_MODELS_DIR

# start the docker image

echo "**** Starting docker image ****"
make run-flea