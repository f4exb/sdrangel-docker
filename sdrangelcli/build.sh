#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-b name] [-t version] [-h]
  Build SDRangel image.
  -b name    Branch name (default master)
  -c tag     Arbitrary clone tag. Clone again if different from the last tag (default current timestamp)
  -i name    Image name (default sdrangelcli)
  -t tag     Docker image tag version (default latest)
  -f file    Specify a Dockerfile (default is Dockerfile in current directory i.e. '.')
  -h         Print this help.
EOF
}

repo_url="https://github.com/f4exb/sdrangelcli.git"
branch_name="master"
clone_tag=$(date)
image_name="sdrangelcli"
image_tag="latest"
uid=$(id -u)
docker_file="."

while getopts "h?r:b:c:i:t:f:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    r)  repo_url=${OPTARG}
        ;;
    b)  branch_name=${OPTARG}
        ;;
    c)  clone_tag=${OPTARG}
        ;;
    i)  image_name=${OPTARG}
        ;;
    t)  image_tag=${OPTARG}
        ;;
    f)  docker_file="-f ${OPTARG} ."
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift
# End of get options

repo_hash=$(echo -n ${repo_url} | gzip -c | tail -c8 | hexdump -n4 -e '"%x"')
IMAGE_NAME=${image_name}:${image_tag}
DOCKER_BUILDKIT=1 docker build \
    --build-arg repository=${repo_url} \
    --build-arg branch=${branch_name} \
    --build-arg repo_hash=${repo_hash} \
    --build-arg clone_tag="${clone_tag}" \
    --build-arg uid=${uid} \
    --target sdrangelcli \
    -t ${IMAGE_NAME} ${docker_file}