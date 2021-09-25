# Tvheadend for TrueNAS

FreeBSD supports much of the same DVB hardware as Linux,
thanks to [webcamd](https://github.com/hselasky/webcamd),
which is a user-space adaptor for Linux drivers.
However, it does not work inside a jail,
so you need to run webcamd outside `iocage`.
[Tvheadened](https://tvheadend.org), which can record and stream the captured television signals,
on the other hand, will run fine in a jail.

The hardware I tried are the [Xbox One Digital TV Tuner](https://www.linuxtv.org/wiki/index.php/Xbox_One_Digital_TV_Tuner)
and the [AVerMedia TD310](https://www.linuxtv.org/wiki/index.php/AVerTV_TD310).
Both can handle DVB-T, DVB-T2, and DVB-C and are easily sourced on eBay and various online shops.
Their main advantage is that the manufacturer does not sell different revisions with different chipsets under the same name -- often only some revisions have Linux support.
In my experience, the Xbox tuner occasionally produces continuity errors in Tvheadend,
while the TD310 works fine so far.

As a first step, clone this repository to your TrueNAS machine:

```bash
git clone https://github.com/mkuron/iocage-plugin-tvheadend.git tvheadend
cd tvheadend
```

## Install cuse.ko

```bash
cd /tmp
curl -LO http://ftp.freebsd.org/pub/FreeBSD/releases/$(uname -m)/$(uname -r | awk -F - '{print $1"-"$2}')/kernel.txz
tar --strip-components=3 -xvf kernel.txz boot/kernel/cuse.ko
mv cuse.ko /boot/modules
```

You will need to repeat these commands after major TrueNAS updates.

## Install DVB firmware

Which firmware file(s) you need depends on your DVB hardware. Plug it into a Linux machine and look at `dmesg` to find out the names of the required files.

```bash
cd /boot/modules
curl -LO https://github.com/OpenELEC/dvb-firmware/raw/master/firmware/dvb-usb-dib0700-1.20.fw
curl -LO https://github.com/armbian/firmware/raw/master/dvb-demod-mn88472-02.fw
curl -LO https://github.com/OpenELEC/dvb-firmware/raw/master/firmware/dvb-usb-it9303-01.fw
curl -LO https://github.com/OpenELEC/dvb-firmware/raw/master/firmware/dvb-demod-si2168-b40-01.fw
```

## Install webcamd

Normally, this would be as simple as

```bash
cd /root/tvheadend
curl -LO https://pkg.freebsd.org/FreeBSD:12:amd64/latest/All/webcamd-5.13.2.6.txz
tar --strip-components=4 -xvf webcamd-5.13.2.6.txz /usr/local/sbin/webcamd
```

Unfortunately, my DVB adapter [requires a patch](https://github.com/hselasky/webcamd/issues/16) to work with webcamd, so I have to build it myself:

```bash
cd /root/tvheadend
iocage create -r $(uname -r | awk -F - '{print $1"-"$2}') -n webcamd ip4_addr="vnet0|192.168.200.24/24" bpf=yes vnet=on defaultrouter=192.168.200.1
iocage start webcamd
iocage exec webcamd pkg install -y git
iocage exec webcamd git clone --recursive https://github.com/hselasky/webcamd.git
sed -i '' 's/= st->channel_state/= (onoff ? 1 : 255)/g' /mnt/iocage/iocage/jails/webcamd/root/webcamd/media_tree/drivers/media/usb/dvb-usb/dib0700_core.c
iocage exec webcamd make -C webcamd patch
iocage exec webcamd make -C webcamd configure HAVE_DVB_DRV=1
iocage exec webcamd make -C webcamd -j 8 HAVE_DVB_DRV=1
cp /mnt/iocage/iocage/jails/webcamd/root/webcamd/webcamd .
cp /mnt/iocage/iocage/jails/webcamd/root/usr/lib/libcuse.so* .
iocage destroy -f webcamd
```

Finally, log into the TrueNAS admin UI, go to _Tasks_, _Init/Shutdown Scripts_, click _ADD_, and add a new _Script_ `/root/tvheadend/webcamd.sh` of type _Post Init_.

## Install tvheadend

```
iocage fetch -P tvheadend.json ip4_addr="vnet0|192.168.200.24/24" vnet=on defaultrouter=192.168.200.1
iocage stop tvheadend
./webcamd.sh
iocage set devfs_ruleset=4265 tvheadend
mkdir /mnt/iocage/tvheadend /mnt/iocage/tvheadend/recordings
iocage fstab tvheadend -a "/mnt/iocage/tvheadend /usr/local/etc/tvheadend nullfs rw 0 0"
iocage fstab tvheadend -a "/mnt/Daten/groups/Filme/Recordings /usr/local/etc/tvheadend/recordings nullfs rw 0 0"
iocage start tvheadend
iocage exec tvheadend service tvheadend stop
iocage exec tvheadend chown tvheadend:tvheadend /usr/local/etc/tvheadend /usr/local/etc/tvheadend/recordings
iocage exec tvheadend "tvheadend -c /usr/local/etc/tvheadend -C -u tvheadend -g tvheadend"
```

Now, open http://192.168.200.24:9981, set a password and complete the setup wizard. Go to Configuration, Recording and set the path to _/usr/local/etc/tvheadend/recordings_. Then, restart the jail to enable authentication:

```bash
iocage restart tvheadend
```
