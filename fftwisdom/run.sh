#!/bin/bash

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-t version] [-c name] [-s fft_sizes] [-f name] [-h]
  Run SDRangel in a Docker container.
  -c name    Docker container name (default fftwisdom)
  -s sizes   FFT sizes in fftwf-wisdom format (default 128 256 512 1024 b128 b256 b512 b1024)
  -t tag     Docker image tag version (default latest). Use the corresponding image tag.
  -f name    FFT wisdom file name in ~/.config/sdrangel (default fftw-wisdom)
  -h         Print this help.
  Examples:
    ./run.sh -s "128 256 512 1024 2048 4096 b128 b256 b512 b1024 b2048 b4096"
    ./run.sh -s "128 256 512 1024 2048 4096 b128 b256 b512 b1024 b2048 b4096" -f fftw-wisdom-4k
EOF
}

image_tag="latest"
container_name="fftwindow"
fft_sizes="128 256 512 1024 b128 b256 b512 b1024"
file_name="fftw-wisdom"
USER_UID=$(id -u)

while getopts "h?c:s:t:f:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    c)  container_name=${OPTARG}
        ;;
    s)  fft_sizes="${OPTARG}"
        ;;
    t)  image_tag=${OPTARG}
        ;;
    f)  file_name=${OPTARG}
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift
# End of get options

mkdir -p /home/${USER}/.config/sdrangel 
docker run -it --rm \
    --privileged \
    --name ${container_name} \
    --env FFTSIZES="${fft_sizes}" \
    --env FFTWFILE=${file_name} \
    -v="/home/${USER}/.config:/home/sdr/.config:rw" \
    fftwisdom:${image_tag}
