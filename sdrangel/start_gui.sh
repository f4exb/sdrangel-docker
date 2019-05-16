#!/bin/bash
sudo service ssh start
sudo service dbus start
sudo service avahi-daemon start
IPADDR=$(ip addr show type veth | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
export LD_LIBRARY_PATH=/opt/install/libsdrplay/lib:/opt/install/xtrx-images/lib:/opt/install/uhd/lib
/bin/bash --init-file <(echo "/opt/install/sdrangel/bin/sdrangel -geometry 600x400+50+50 -a ${IPADDR}") # Drop to a shell when exiting SDRangel