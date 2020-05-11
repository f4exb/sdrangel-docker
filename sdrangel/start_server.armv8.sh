#!/bin/bash
IPADDR=$(ip addr show eth0 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)
export LD_LIBRARY_PATH=/opt/install/xtrx-images/lib
# Drop to a shell when exiting SDRangel
/bin/bash --init-file <(echo "/opt/install/sdrangel/bin/sdrangelsrv -a ${IPADDR} -w ~/.config/sdrangel/fftw-wisdom")