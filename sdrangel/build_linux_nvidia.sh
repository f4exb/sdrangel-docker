#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-b branch] [-c label] [-t tag] [-h]
  Build SDRangel image.
  -b name    Branch name (default master)
  -c label   Arbitrary clone label. Clone again if different from the last label (default current timestamp)
  -t tag     Docker image tag. Use git tag or commit hash (default latest)
  -j number  Number of cores used in make commands (-j), Default is the number of cores available.
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

IMAGE_NAME=sdrangel/nvidia:${image_tag}
NVIDIA_VER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader) #410.78
NVIDIA_DRIVER=NVIDIA-Linux-x86_64-${NVIDIA_VER}.run  # path to nvidia driver

if [ ! -f ${NVIDIA_DRIVER} ]; then
    wget http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_VER}/NVIDIA-Linux-x86_64-${NVIDIA_VER}.run
    cp ${NVIDIA_DRIVER} NVIDIA-DRIVER.run
fi

DOCKER_BUILDKIT=1 docker build \
    --build-arg branch=${branch_name} \
    --build-arg clone_label="${clone_label}" \
    --build-arg nb_cores=${nb_cores} \
    --build-arg uid=${uid} \
    --target linux_nvidia \
    -t ${IMAGE_NAME} .
