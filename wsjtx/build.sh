#!/bin/bash

IMAGE_NAME=wsjtx/bionic:libfaketime
DOCKER_BUILDKIT=1 docker build -t ${IMAGE_NAME} .
