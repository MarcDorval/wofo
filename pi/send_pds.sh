#!/bin/bash
# send_pds.sh <your_file.pds>
#  or
# send_pds.sh <your_file.pds.in>
# (will compress if needed, based on the extension)

SEND_PDS="/sys/kernel/debug/ieee80211/phy0/wfx/send_pds"
PDS_FOLDER="/home/pi/wfx_pds"

SEND_PDS_OPEN=$(sudo ls $SEND_PDS)
if [ -z "$SEND_PDS_OPEN" ]; then
	echo "file $SEND_PDS not found! The WFx200 driver is probably not loaded..."
	exit 1
fi

if [ -z "$1" ]; then
	echo "You need to provide a .pds or .pds.in filename!"
	exit 1
fi

if [ ! -e "$1" ]; then
	echo "file $1 not found!"
	exit 1
fi

PDS=$(echo $1 | grep "\.pds")
if [ -z "$PDS" ]; then
	echo "'$1' is not a pds file!"
	exit 1
fi

UNCOMPRESSED=$(echo $1 | grep "\.pds\.in")
if [ ! -z "$UNCOMPRESSED" ]; then
	# We need to be in the PDS folder to properly include the dictionary.
	SRC_FOLDER=$(pwd)
	cd $PDS_FOLDER
	pds_compress $1 | sudo tee $SEND_PDS
	cd $SRC_FOLDER
else
	cat          $1 | sudo tee $SEND_PDS
fi
