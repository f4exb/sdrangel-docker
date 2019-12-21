#!/bin/bash
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-t version] [-h]
  Build WSKT-X with clock adjustment Docker image.
  -t version WSJT-X version (default 2.1.2)
  -h         Print this help.
EOF
}

version="2.1.2"

while getopts "h?t:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    t)  version=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

nb_cores=$(grep -c ^processor /proc/cpuinfo)
IMAGE_NAME=wsjtx/bionic:v${version}
DOCKER_BUILDKIT=1 docker build \
    --build-arg nb_cores=${nb_cores} \
    --build-arg wsjtx_version=${version} \
    -t ${IMAGE_NAME} .
