#!/bin/sh

IMAGE_NAME=sdrangel/bionic:server24
DOCKER_BUILDKIT=1 docker build --target server24 -t ${IMAGE_NAME} .