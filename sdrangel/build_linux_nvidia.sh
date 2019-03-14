#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-r url] [-b name] [-t version] [-h]
  Build SDRangel image.
  -r         Repository URL (default https://github.com/f4exb/sdrangel.git)
  -b         Branch name (default master)
  -t version Docker image tag version (default linux_nvidia)
  -h         Print this help.
EOF
}

repo_url="https://github.com/f4exb/sdrangel.git"
branch_name="master"
image_tag="linux_nvidia"

while getopts "h?r:b:t:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    r)  repo_url=${OPTARG}
        ;;
    b)  branch_name=${OPTARG}
        ;;
    t)  image_tag=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift
# End of get options

IMAGE_NAME=sdrangel/${branch_name}:${image_tag}
NVIDIA_VER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader) #410.78
NVIDIA_DRIVER=NVIDIA-Linux-x86_64-${NVIDIA_VER}.run  # path to nvidia driver

if [ ! -f ${NVIDIA_DRIVER} ]; then
    wget http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_VER}/NVIDIA-Linux-x86_64-${NVIDIA_VER}.run
    cp ${NVIDIA_DRIVER} NVIDIA-DRIVER.run
fi

DOCKER_BUILDKIT=1 docker build \
    --build-arg repository=${repo_url} \
    --build-arg branch=${branch_name} \
    --target linux_nvidia \
    -t ${IMAGE_NAME} .
