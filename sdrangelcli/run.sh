#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-t version] [-p port] [-h]
  Run SDRangel client in a Docker container.
  -t version Docker image tag version (default latest)
  -p port    http port map to 8080 (default 8080)
  -h         Print this help.
EOF
}

http_port="-p 8080:8080"
image_tag="latest"

while getopts "h?gs:a:u:t:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    p)  http_port="-p ${OPTARG}:8080"
        ;;
    t)  image_tag=$OPTARG
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
    ${http_port} \
    sdrangelcli/node:${image_tag}
