#!/bin/sh

IMAGE_NAME=sdrangel/bionic:vanilla
DOCKER_BUILDKIT=1 docker build --target vanilla -t ${IMAGE_NAME} .