#!/bin/bash
sudo service dbus start
sudo service avahi-daemon start
IPADDR=$(ip addr show type veth | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
export LD_LIBRARY_PATH=/opt/install/libsdrplay/lib:/opt/install/xtrx-images/lib
# Drop to a shell when exiting SDRangel
/bin/bash --init-file <(echo "/opt/install/sdrangel/bin/sdrangelsrv -a ${IPADDR} -w ~/.config/sdrangel/${FFTWFILE}")
