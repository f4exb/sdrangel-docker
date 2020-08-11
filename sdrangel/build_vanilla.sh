#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-b branch] [-T tag] [-c label] [-t tag] [-n] [-h]
  Build SDRangel image.
  -b name    Branch name (default master)
  -T tag     Checkout tag or commit (default to branch name i.e. do nothing)
  -c label   Arbitrary clone label. Clone again if different from the last labl (default current timestamp)
  -t tag     Docker image tag. Use git tag or commit hash (default latest)
  -j number  Number of cores used in make commands (-j), Default is half the number of cores available.
  -n         Force the no cahe option (--no-cache)
  -h         Print this help.
EOF
}

no_cache=""
branch_name="master"
clone_label=$(date)
image_tag="latest"
nb_cores=$(grep -c ^processor /proc/cpuinfo)
uid=$(id -u)

while getopts "h?b:c:t:j:T:n" opt; do
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
    T)  sdrangel_tag=${OPTARG}
        ;;
    n)  no_cache="--no-cache"
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift
# End of get options

if [ -z ${sdrangel_tag+x} ]; then
    sdrangel_tag=${branch_name}
fi

repo_hash=$(echo -n ${repo_url} | gzip -c | tail -c8 | hexdump -n4 -e '"%x"')
IMAGE_NAME=sdrangel/vanilla:${image_tag}
DOCKER_BUILDKIT=1 docker build ${no_cache} \
    --build-arg branch=${branch_name} \
    --build-arg sdrangel_tag=${sdrangel_tag} \
    --build-arg clone_label="${clone_label}" \
    --build-arg nb_cores=${nb_cores} \
    --build-arg uid=${uid} \
    --target vanilla \
    -t ${IMAGE_NAME} .