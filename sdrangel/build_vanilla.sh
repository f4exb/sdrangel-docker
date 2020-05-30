#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-b branch] [-c label] [-t tag] [-h]
  Build SDRangel image.
  -b name    Branch name (default master)
  -c label   Arbitrary clone label. Clone again if different from the last labl (default current timestamp)
  -t tag     Docker image tag. Use git tag or commit hash (default latest)
  -j number  Number of cores used in make commands (-j), Default is half the number of cores available.
  -h         Print this help.
EOF
}

branch_name="master"
clone_label=$(date)
image_tag="latest"
nb_cores=$(grep -c ^processor /proc/cpuinfo)
uid=$(id -u)

while getopts "h?b:c:t:j:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    b)  branch_name=${OPTARG}
        ;;
    c)  clone_label=${OPTARG}
        ;;
    t)  image_tag=${OPTARG}
        ;;
    j)  nb_cores=${OPTARG}
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift
# End of get options

repo_hash=$(echo -n ${repo_url} | gzip -c | tail -c8 | hexdump -n4 -e '"%x"')
IMAGE_NAME=sdrangel/vanilla:${image_tag}
DOCKER_BUILDKIT=1 docker build \
    --build-arg branch=${branch_name} \
    --build-arg clone_label="${clone_label}" \
    --build-arg nb_cores=${nb_cores} \
    --build-arg uid=${uid} \
    --target vanilla \
    -t ${IMAGE_NAME} .