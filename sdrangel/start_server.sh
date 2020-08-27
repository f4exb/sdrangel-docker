#!/bin/bash
sudo service dbus start
sudo service avahi-daemon start
if [ -z ${IPADDR+x} ]; then # take container virtual address if not specified
    IPADDR=$(ip addr show type veth | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
fi
if [ -z ${APIPORT+x} ]; then # take 8091 port for API if not specified
    APIPORT=8091
fi
export LD_LIBRARY_PATH=/opt/install/libsdrplay/lib:/opt/install/xtrx-images/lib
# Drop to a shell when exiting SDRangel
/bin/bash --init-file <(echo "/opt/install/sdrangel/bin/sdrangelsrv -a ${IPADDR} p ${APIPORT} -w ~/.config/sdrangel/${FFTWFILE}")
