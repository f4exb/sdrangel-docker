#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-g] [-b branch] -t version [-k name] [-s port] [-a port] [-u port [-u port ...]] [-h]
  Run SDRangel in a Docker container.
  -g         Run a GUI variant (server if unset)
  -b         SDRangel source branch name (default master)
  -t version Docker image tag version
  -c name    Docker container name (default sdrangel)
  -s port    SSH port map to 22.
  -a port    API port map to 8091 (default 8091).
  -u port    UDP port map to same with UDP option. Can be repeated.
  -h         Print this help.
EOF
}

gui_opts=""
ssh_port=""
api_port="-p 8091:8091"
udp_conn=""
branch_name="master"
image_tag=""
container_name="sdrangel"
USER_UID=$(id -u)

while getopts "h?gs:a:u:b:t:c:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    g)  gui_opts="-e PULSE_SERVER=unix:/run/user/${USER_UID}/pulse/native -e DISPLAY=unix:0.0 -v=/tmp/.X11-unix:/tmp/.X11-unix:rw"
        ;;
    s)  ssh_port="-p ${OPTARG}:22"
        ;;
    a)  api_port="-p ${OPTARG}:8091"
        ;;
    u)  udp_conn="-p ${OPTARG}:${OPTARG}/udp ${udp_conn}"
        ;;
    b)  branch_name=$OPTARG
        ;;
    t)  image_tag=$OPTARG
        ;;
    c)  container_name=$OPTARG
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
docker run -it --rm \
    --privileged \
    --name ${container_name} \
    ${gui_opts} \
    ${ssh_port} \
    ${api_port} \
    ${udp_conn} \
    -v="/home/${USER}/.config:/home/sdr/.config:rw" \
    -v="/run/user/${USER_UID}/pulse:/run/user/${USER_UID}/pulse" \
    sdrangel/${branch_name}:${image_tag}
