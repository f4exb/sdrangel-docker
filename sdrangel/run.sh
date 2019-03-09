#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-g] -t version [-s port] [-a port] [-u port [-u port ...]] [-h]
  Run SDRangel in a Docker container.
  -g         Run a GUI variant (server if unset)
  -t version Docker image tag version
  -s port    SSH port map to 22.
  -a port    API port map to 8091 (default 8091).
  -u port    UDP port map to same with UDP option. Can be repeated.
  -h         Print this help.
EOF
}

udp_conn=""
api_port="-p 8091:8091"
ssh_port=""
image_tag=""
gui_opts=""

while getopts "h?gs:a:u:t:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    g)  gui_opts="-e PULSE_SERVER=unix:/run/user/1000/pulse/native -e DISPLAY=unix:0.0 -v=/tmp/.X11-unix:/tmp/.X11-unix:rw"
        ;;
    s)  ssh_port="-p ${OPTARG}:22"
        ;;
    a)  api_port="-p ${OPTARG}:8091"
        ;;
    t)  image_tag=$OPTARG
        ;;
    u)  udp_conn="-p ${OPTARG}:${OPTARG}/udp ${udp_conn}"
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
docker run -it --rm --privileged \
    ${gui_opts} \
    ${ssh_port} \
    ${api_port} \
    ${udp_conn} \
    -v="/home/${USER}/.config:/home/sdr/.config:rw" \
    -v="/run/user/${USER_UID}/pulse:/run/user/1000/pulse" \
    sdrangel/bionic:${image_tag}
