#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-r url] [-b branch] [-t tag] [-h]
  Build SDRangel image.
  -r url     Repository URL (default https://github.com/f4exb/sdrangel.git)
  -b name    Branch name (default master)
  -c tag     Arbitrary clone tag. Clone again if different from the last tag (default current timestamp)
  -t tag     Docker image tag. Use git tag or commit hash (default latest)
  -j number  Number of cores used in make commands (-j), Default is the number of cores available.
  -h         Print this help.
EOF
}

repo_url="https://github.com/f4exb/sdrangel.git"
branch_name="master"
clone_tag=$(date)
image_tag="latest"
nb_cores=$(grep -c ^processor /proc/cpuinfo)
uid=$(id -u)

while getopts "h?r:b:c:t:j:" opt; do
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
IMAGE_NAME=sdrangel/nvidia:${image_tag}
NVIDIA_VER=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader) #410.78
NVIDIA_DRIVER=NVIDIA-Linux-x86_64-${NVIDIA_VER}.run  # path to nvidia driver

if [ ! -f ${NVIDIA_DRIVER} ]; then
    wget http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_VER}/NVIDIA-Linux-x86_64-${NVIDIA_VER}.run
    cp ${NVIDIA_DRIVER} NVIDIA-DRIVER.run
fi

DOCKER_BUILDKIT=1 docker build \
    --build-arg repository=${repo_url} \
    --build-arg branch=${branch_name} \
    --build-arg repo_hash=${repo_hash} \
    --build-arg clone_tag="${clone_tag}" \
    --build-arg nb_cores=${nb_cores} \
    --build-arg uid=${uid} \
    --target linux_nvidia \
    -t ${IMAGE_NAME} .
