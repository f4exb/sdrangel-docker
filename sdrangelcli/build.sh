#!/bin/sh

IMAGE_NAME=sdrangelcli/node:latest
DOCKER_BUILDKIT=1 docker build -t ${IMAGE_NAME} .