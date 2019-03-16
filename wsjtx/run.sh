#!/bin/bash
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-t version] [-p port] [-h]
  Run WSKT-X with clock adjustment in a Docker container.
  -t version Docker image tag version (default libfaketime)
  -d delay   delay in seconds (default 4)
  -h         Print this help.
EOF
}

delay="-4s"
image_tag="libfaketime"

while getopts "h?gd:t:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    d)  delay="-${OPTARG}s"
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

# Run...
touch /home/${USER}/WSJT-X.ini
USER_UID=$(id -u)
docker run -it --rm \
    --privileged \
    --name "wsjtx" \
    -e "FAKETIME=${delay}" \
    -e "PULSE_SERVER=unix:/run/user/1000/pulse/native" \
    -e "DISPLAY=unix:0.0" \
    -v="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    -v="/run/user/${USER_UID}/pulse:/run/user/1000/pulse" \
    -v="/home/${USER}/WSJT-X.ini:/home/wsjtx/.config/WSJT-X.ini:rw" \
    wsjtx/bionic:${image_tag}
