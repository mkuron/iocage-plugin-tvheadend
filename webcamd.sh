#!/bin/bash

cd $(dirname $0)
kldload cuse

DEV_NAME="Microsoft Corp. Xbox USB Tuner"
UGEN_DEV=$(usbconfig | grep "$DEV_NAME" | cut -d':' -f 1)
if [ "$UGEN_DEV" != "" ]; then
	LD_LIBRARY_PATH=$PWD nice -n -10 ./webcamd -d $UGEN_DEV -B
fi

DEV_NAME="AVerMedia TD310 Device"
UGEN_DEV=$(usbconfig | grep "$DEV_NAME" | cut -d':' -f 1)
if [ "$UGEN_DEV" != "" ]; then
	LD_LIBRARY_PATH=$PWD nice -n -10 ./webcamd -d $UGEN_DEV -B
fi

DEV_NAME="CityCom GmbH TechnoTrend USB-Stick"
UGEN_DEV=$(usbconfig | grep "$DEV_NAME" | cut -d':' -f 1)
if [ "$UGEN_DEV" != "" ]; then
	LD_LIBRARY_PATH=$PWD nice -n -10 ./webcamd -d $UGEN_DEV -B
fi

./rules.sh
