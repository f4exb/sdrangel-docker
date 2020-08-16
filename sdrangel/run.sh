#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-g] -t version [-k name] [-a port] [-u port [-u port ...]] [-h]
  Run SDRangel in a Docker container.
  -g         Run a GUI variant (server if unset)
  -f         Image flavor. Can be vanilla, nvidia, server16, server24 (default vanilla). Use a flavor relevant to GUI or server variants.
  -t tag     Docker image tag version (default latest). Use the corresponding image tag.
  -c name    Docker container name (default sdrangel)
  -a port    API port map to 8091 (default 8091).
  -u port    UDP port map to same with UDP option. Can be repeated.
  -w name    FFTW wisdom file name in the `~/.config/sdrangel` directory (default fftw-wisdom).
  -h         Print this help.
  Examples:
    ./run.sh -g -c sdrangel -u 9090:9090 (starts sdrangel/vanilla:latest)
    ./run.sh -g -f nvidia -t v4.10.4 -c sdrangel -u 9090:9090 (starts sdrangel/nvidia:v4.10.4)
    ./run.sh -f server16 -t 38df0a6 -c sdrangel -u 9090:9090 (starts sdrangel/server16:38df0a6)
EOF
}

gui_opts=""
ssh_port=""
api_port="-p 8091:8091"
udp_conn=""
flavor="vanilla"
image_tag="latest"
container_name="sdrangel"
fftw_filename="fftw-wisdom"
USER_UID=$(id -u)

while getopts "h?ga:u:f:t:c:w:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    g)  gui_opts="-e DISPLAY=unix:0.0 -v=/tmp/.X11-unix:/tmp/.X11-unix:rw -v=/var/run/dbus:/var/run/dbus -v=/var/run/avahi-daemon/socket:/var/run/avahi-daemon/socket"
        ;;
    a)  api_port="-p ${OPTARG}:8091"
        ;;
    u)  udp_conn="-p ${OPTARG}:${OPTARG}/udp ${udp_conn}"
        ;;
    f)  flavor=$OPTARG
        ;;
    t)  image_tag=$OPTARG
        ;;
    c)  container_name=$OPTARG
        ;;
    w)  fftw_filename=$OPTARG
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
    ${api_port} \
    ${udp_conn} \
    --env FFTWFILE=${fftw_filename} \
    --env PULSE_SERVER="unix:/run/user/${USER_UID}/pulse/native" \
    -v="/home/${USER}/.config:/home/sdr/.config:rw" \
    -v="/run/user/${USER_UID}/pulse:/run/user/${USER_UID}/pulse" \
    sdrangel/${flavor}:${image_tag}
