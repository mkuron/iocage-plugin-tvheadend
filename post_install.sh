#!/bin/sh

echo 'tvheadend_enable=YES' >> /etc/rc.conf
pw usermod tvheadend -G webcamd
