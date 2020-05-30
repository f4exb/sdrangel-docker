#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-b branch] [-c label] [-t tag] [-h]
  Build SDRangel image.
  -b name    Branch name (default master)
  -c label   Arbitrary clone label. Clone again if different from the last label (default current timestamp)
  -x         Use 24 bit samples for Rx
  -t tag     Docker image tag. Use git tag or commit hash (default latest)
  -j number  Number of cores used in make commands (-j), Default is the number of cores available.
  -f file    Specify a Dockerfile (default is Dockerfile in current directory i.e. '.')
  -h         Print this help.
EOF
}

branch_name="master"
clone_label=$(date)
image_tag="latest"
rx_24bits="OFF"
rx_bits="16"
nb_cores=$(grep -c ^processor /proc/cpuinfo)
uid=$(id -u)
docker_file="."

while getopts "h?b:c:xt:j:f:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    b)  branch_name=${OPTARG}
        ;;
    c)  clone_label=${OPTARG}
        ;;
    x)  rx_24bits="ON"
        rx_bits="24"
        ;;
    t)  image_tag=${OPTARG}
        ;;
    j)  nb_cores=${OPTARG}
        ;;
    f)  docker_file="-f ${OPTARG} ."
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift
# End of get options

IMAGE_NAME=sdrangel/server${rx_bits}:${image_tag}
DOCKER_BUILDKIT=1 docker build \
    --build-arg branch=${branch_name} \
    --build-arg clone_label="${clone_label}" \
    --build-arg rx_24bits=${rx_24bits} \
    --build-arg nb_cores=${nb_cores} \
    --build-arg uid=${uid} \
    --target server \
    -t ${IMAGE_NAME} ${docker_file}