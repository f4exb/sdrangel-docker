#!/bin/bash
if [ -z ${IPADDR+x} ]; then # take container virtual address if not specified
    IPADDR=$(ip addr show type veth | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
fi
if [ -z ${APIPORT+x} ]; then # take 8091 port for API if not specified
    APIPORT=8091
fi
export LD_LIBRARY_PATH=/opt/install/libsdrplay/lib:/opt/install/xtrx-images/lib
/opt/install/sdrangel/bin/sdrangel -geometry 600x400+50+50 -a ${IPADDR} -p ${APIPORT} -w ~/.config/sdrangel/${FFTWFILE}