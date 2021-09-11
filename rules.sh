#!/bin/sh
# Custom ruleset for jails

export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

RULESET=4265
DEV_NAME="Microsoft Corp. Xbox USB Tuner"

# Find the device.
UGEN_DEV=$(usbconfig | grep "$DEV_NAME" | cut -d':' -f 1)
USB_DEV=$(readlink /dev/$UGEN_DEV)

if [ -z "$UGEN_DEV" -o -z "$USB_DEV" ]
then
  echo "error: cannot find device '$DEV_NAME'"
  echo "error: please check with usbconfig"
  exit 1
fi

echo "Found $DEV_NAME on $UGEN_DEV"

# Clean the ruleset
devfs rule -s $RULESET delset

# Include jails default ruleset and unhide USB device.
devfs rule -s $RULESET add include 4
devfs rule -s $RULESET add path usb unhide
devfs rule -s $RULESET add path $USB_DEV mode 660 unhide
devfs rule -s $RULESET add path $UGEN_DEV mode 660 unhide
devfs rule -s $RULESET add path usbctl mode 644 unhide
devfs rule -s $RULESET add path dvb mode 644 unhide
devfs rule -s $RULESET add path dvb/adapter* mode 644 unhide
devfs rule -s $RULESET add path 'dvb/adapter*/*' mode 644 unhide
devfs rule -s $RULESET add path cuse mode 644 unhide
