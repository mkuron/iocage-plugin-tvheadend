#!/bin/sh

echo 'tvheadend_enable=YES' >> /etc/rc.conf
pw usermod tvheadend -G webcamd
echo 'redir_enable=YES' >> /etc/rc.conf
echo 'redir_flags="--lport=80 --cport=9981"' >> /etc/rc.conf
