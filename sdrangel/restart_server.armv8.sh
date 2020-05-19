#!/bin/bash
export LD_LIBRARY_PATH=/opt/install/libsdrplay/lib:/opt/install/xtrx-images/lib
IPADDR=$(ip addr show eth0 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
/opt/install/sdrangel/bin/sdrangelsrv -a ${IPADDR} -w ~/.config/sdrangel/${FFTWFILE}