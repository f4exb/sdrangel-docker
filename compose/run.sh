#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-g] -t version [-n name] [-r bits] [-w port] [-s port] [-a port] [-u port[-port]] [-h]
  Run SDRangel in a Docker container.
  -g         Run a GUI variant (server if unset)
  -t version Docker GUI image tag version
  -r         Number of Rx bits for server version (default 16)
  -n         Container name suffix (default 1)
  -w port    Web client port map to 8080 (default 8080)
  -s port    SSH port map to 22 (default 50022).
  -a port    API port map to 8091 (default 8091).
  -u port(s) UDP port(s) map to same with UDP option (default 9090). You can specify a range as XXXX-YYYY.
  -h         Print this help.
EOF
}

image_tag=""
name_suffix="1"
rx_bits="16"
web_port="8080"
ssh_port="50022"
api_port="8091"
udp_port="9090"
run_gui=0

while getopts "h?gt:r:w:s:a:u:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    g)  run_gui=1
        ;;
    t)  image_tag=${OPTARG}
        ;;
    r)  rx_bits=${OPTARG}
        ;;
    n)  name_suffix=${OPTARG}
        ;;
    w)  web_port=${OPTARG}
        ;;
    s)  ssh_port=${OPTARG}
        ;;
    a)  api_port=${OPTARG}
        ;;
    u)  udp_port=${OPTARG}
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift
# End of get options

export USER_UID=$(id -u)
export IMAGE_VERSION=${image_tag}
export NAME_SUFFIX=${name_suffix}
export WEB_PORT=${web_port}
export SSH_PORT=${ssh_port}
export API_PORT=${api_port}
export UDP_PORT=${udp_port}
export RX_BITS=${rx_bits}

if [ "$run_gui" -eq 1 ]; then
    docker-compose -f compose_gui.yml up -d
else
    docker-compose -f compose_server.yml up -d
fi