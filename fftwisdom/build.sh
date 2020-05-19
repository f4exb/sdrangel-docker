#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-t version] [-h]
  Build SDRangel image.
  -t tag     Docker image tag version (default latest)
  -h         Print this help.
EOF
}

uid=$(id -u)
image_tag="latest"

while getopts "h?t:f:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    t)  image_tag=${OPTARG}
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift
# End of get options

IMAGE_NAME=fftwisdom:${image_tag}
DOCKER_BUILDKIT=1 docker build \
    --build-arg uid=${uid} \
    -t ${IMAGE_NAME} .