#!/bin/bash

if [ $# -lt 1 ]; then
	echo "Specify the guest to modify"
	exit -1
fi

GUEST=$1

# update vgamem to 32MB to allow full screen on our widescreen displays
virsh dumpxml $GUEST > $GUEST.xml

if [ $? -ne 0 ]; then
	echo "$GUEST not found"
	virsh list --all
	rm -f $GUEST.xml
	exit -1
fi

sed -i "s/vgamem='[0-9]*'/vgamem='32768'/" $GUEST.xml
virsh define $GUEST.xml
rm -f $GUEST.xml


