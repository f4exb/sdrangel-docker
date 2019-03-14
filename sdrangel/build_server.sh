#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-r url] [-b name] [-t version] [-h]
  Build SDRangel image.
  -r         Repository URL (default https://github.com/f4exb/sdrangel.git)
  -b         Branch name (default master)
  -x         Use 24 bit samples for Rx
  -t version Docker image tag version (default server{bits})
  -h         Print this help.
EOF
}

repo_url="https://github.com/f4exb/sdrangel.git"
branch_name="master"
image_tag="server"
rx_24bits="OFF"
rx_bits="16"

while getopts "h?r:b:xt:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    r)  repo_url=${OPTARG}
        ;;
    b)  branch_name=${OPTARG}
        ;;
    x)  rx_24bits="ON"
        rx_bits="24"
        ;;
    t)  image_tag=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift
# End of get options

IMAGE_NAME=sdrangel/${branch_name}:${image_tag}${rx_bits}
DOCKER_BUILDKIT=1 docker build \
    --build-arg repository=${repo_url} \
    --build-arg branch=${branch_name} \
    --build-arg rx_24bits=${rx_24bits} \
    --target server \
    -t ${IMAGE_NAME} .