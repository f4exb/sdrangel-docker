#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-t version] [-p port] [-h]
  Run SDRangelSpectrum client in a Docker container.
  -i name    Docker image name (default sdrangelcli)
  -t tag     Docker image tag version (default latest)
  -c name    Docker container name (default sdrangelcli)
  -p port    http port map to 8081 (default 8081)
  -h         Print this help.
EOF
}

image_name="sdrangelspectrum"
image_tag="latest"
container_name="sdrangelspectrum"
http_port="-p 8081:8081"

while getopts "h?gi:t:c:p:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    i)  image_name=${OPTARG}
        ;;
    t)  image_tag=${OPTARG}
        ;;
    c)  container_name=${OPTARG}
        ;;
    p)  http_port="-p ${OPTARG}:8081"
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift
# End of get options

# ensure xhost permissions for GUI operation
if [ ! -z "$gui_opts" ]; then
    xhost +si:localuser:${USER}
fi
# Start of launching script
USER_UID=$(id -u)
docker run -it --rm \
    --name ${container_name} \
    ${http_port} \
    ${image_name}:${image_tag}
