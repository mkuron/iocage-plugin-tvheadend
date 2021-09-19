#!/bin/bash

DEV_NAME="Microsoft Corp. Xbox USB Tuner"
UGEN_DEV=$(usbconfig | grep "$DEV_NAME" | cut -d':' -f 1)

cd $(dirname $0)
kldload cuse
LD_LIBRARY_PATH=$PWD nice -n -10 ./webcamd -d $UGEN_DEV -B

./rules.sh
