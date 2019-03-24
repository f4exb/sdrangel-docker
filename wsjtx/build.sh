#!/bin/bash

nb_cores=$(grep -c ^processor /proc/cpuinfo)
IMAGE_NAME=wsjtx/bionic:libfaketime
DOCKER_BUILDKIT=1 docker build \
    --build-arg nb_cores=${nb_cores} \
    -t ${IMAGE_NAME} .
