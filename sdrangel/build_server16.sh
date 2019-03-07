#!/bin/sh

IMAGE_NAME=sdrangel/bionic:server16
DOCKER_BUILDKIT=1 docker build --target server16 -t ${IMAGE_NAME} .