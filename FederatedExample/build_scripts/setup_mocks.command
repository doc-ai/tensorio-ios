#!/bin/sh


FLEA_DOCKER_PORT=8083

# Set terminal title

echo -en "\\033]0;TensorIO Flea Mocks\\a"
clear

# Wait for serving connection to the docker image

while ! nc -z localhost $FLEA_DOCKER_PORT; do   
  sleep 0.25
done

while ! curl -s http://localhost:$FLEA_DOCKER_PORT/v1/flea/healthz | grep "SERVING"; do
  sleep 0.25
done

# tensorio-models directory

if [[ -z "${TENSORIO_MODELS_DIR}" ]]; then
  TENSORIO_MODELS_DIR=~/repos/tensorio-models/
fi
cd $TENSORIO_MODELS_DIR

# start the docker image

echo "**** Setting up mocks ****"
./e2e/create-sample-tasks.sh
