#!/bin/sh

export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"

RULESET=4265

# Clean the ruleset
devfs rule -s $RULESET delset

# Include jails default ruleset and unhide DVB device.
devfs rule -s $RULESET add include 4
devfs rule -s $RULESET add path dvb mode 555 unhide
devfs rule -s $RULESET add path dvb/adapter* mode 555 unhide
devfs rule -s $RULESET add path 'dvb/adapter*/*' mode 660 unhide
devfs rule -s $RULESET add path cuse mode 664 unhide
