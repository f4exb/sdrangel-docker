#!/bin/sh

OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Get options:
show_help() {
  cat << EOF
  Usage: ${0##*/} [-g] [-b branch] -t version [-n name] [-r bits] [-w port] [-s port] [-a port] [-u port[-port]] [-h]
  Run SDRangel and SDRangelCli in a Docker compose stack.
  -g         Run a GUI variant (server if unset)
  -b         SDRangel source branch name (default master)
  -t version Docker GUI image tag version
  -c name    Docker compose stack name (default compose)
  -r         Number of Rx bits for server version (default 16)
  -n         Container name suffix (default 1)
  -w port    Web client port map to 8080 (default 8080)
  -s port    SSH port map to 22 (default 50022).
  -a port    API port map to 8091 (default 8091).
  -u port(s) UDP port(s) map to same with UDP option (default 9090). You can specify a range as XXXX-YYYY.
  -h         Print this help.
EOF
}

branch_name="master"
image_tag=""
name_suffix="1"
stack_name=""
rx_bits="16"
web_port="8080"
ssh_port="50022"
api_port="8091"
udp_port="9090"
run_gui=0
action="up"

while getopts "h?Dgb:t:c:r:w:s:a:u:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    D)  action="down"
        ;;
    g)  run_gui=1
        ;;
    b)  branch_name=${OPTARG}
        ;;
    t)  image_tag=${OPTARG}
        ;;
    c)  stack_name="-p ${OPTARG}"
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

export DNS=$(nmcli dev show | grep 'IP4.DNS' | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
export USER_UID=$(id -u)
export BRANCH_NAME=${branch_name}
export IMAGE_VERSION=${image_tag}
export NAME_SUFFIX=${name_suffix}
export WEB_PORT=${web_port}
export SSH_PORT=${ssh_port}
export API_PORT=${api_port}
export UDP_PORT=${udp_port}
export RX_BITS=${rx_bits}

if [ "$run_gui" -eq 1 ]; then
    docker-compose -f compose_gui.yml ${stack_name} ${action} -d
else
    docker-compose -f compose_server.yml ${stack_name} ${action} -d
fi