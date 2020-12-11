#!/bin/bash

if [ $# -lt 2 ]; then
	echo "Usage: $0 [-u] <OS name> <pcie slot>"
	echo "           -u: only map user function"
	echo "For example: $0 centos7.5 af"
	echo
	echo "OS list:"
	virsh list --all
	echo
	echo "========================================================"
	echo
	echo "Xilinx devices:"
	[ -f /opt/xilinx/xrt/bin/xbmgmt ] && /opt/xilinx/xrt/bin/xbmgmt scan || lspci -d 10ee:
	echo
	echo
	echo "========================================================"
	echo
	for dev in $(virsh list --all --name); do
		devices=$(virsh dumpxml $dev | grep '<hostdev' -A 5 | grep "function='0x1'" | grep -v "type" | tr -s ' ' | cut -d' ' -f4 | cut -d= -f2 | awk '{print substr($0,4,2);}')
		if [[ ! -z "$devices" ]]; then
			echo "Attached host devices in $dev:"
			echo $devices
			echo
		fi
	done
	exit -1
fi

MAP_MGMT=1
if [ "$1" = "-u" ]; then
	MAP_MGMT=0
	shift
fi

export OS=$1
export DEV=$2

#not sure what to pick for SLOT. Testing shows that on q35 systems, SLOT 0x00 works, and on i440fx systems, slot 0x01 works...
SLOT="01"
if $(virsh dumpxml $OS | grep q35 &> /dev/null); then
	SLOT="00"
fi
export SLOT

CMD=$(basename $0)
COMMAND=${CMD%.sh}

if [ $MAP_MGMT -eq 1 ]; then
	envsubst < pass-mgmt.xml_base > pass-mgmt-$DEV-$OS.xml
	virsh $COMMAND-device $OS --file pass-mgmt-$DEV-$OS.xml --config
fi

envsubst < pass-user.xml_base > pass-user-$DEV-$OS.xml
virsh $COMMAND-device $OS --file pass-user-$DEV-$OS.xml --config

rm -f pass-mgmt-$DEV-$OS.xml pass-user-$DEV-$OS.xml

