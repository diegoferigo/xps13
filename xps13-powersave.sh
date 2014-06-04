#!/bin/bash

if [ "$1" = "unplugged" ] ; then
	#
	AC_UNPLUGGED="1"
	AC_PLUGGED="0"
	#
	DIRTY_WRITEBACK="1500"
	LAPTOP_MODE="5"
	TOUCHSCREEN_AUTOSUSPEND="auto"
	POWER_SAVE_CONTROLLER="Y"
	SATA_POWERSAVING="min_power"
	PCI_I2C_USB_POWER_CONTROL="auto"
	USB_AUTOSUSPEND="10"
	WIRELESS_POWERSAVE="on"
elif [ "$1" = "plugged" ] ; then
	#
	AC_UNPLUGGED="0"
	AC_PLUGGED="1"
	#
	DIRTY_WRITEBACK="500"
	LAPTOP_MODE="0"
	TOUCHSCREEN_AUTOSUSPEND="on"
	POWER_SAVE_CONTROLLER="N"
	SATA_POWERSAVING="max_performance"
	PCI_I2C_USB_POWER_CONTROL="on"
	USB_AUTOSUSPEND="600"
	WIRELESS_POWERSAVE="off"
else
	exit 1
fi

Echo()
{
	if [ -e $2 ] ; then
		echo $1 > $2
	else
		break
	fi
}

Echo ${DIRTY_WRITEBACK}         '/proc/sys/vm/dirty_writeback_centisecs'
Echo ${LAPTOP_MODE}             '/proc/sys/vm/laptop_mode'
Echo ${POWER_SAVE_CONTROLLER}   '/sys/module/snd_hda_intel/parameters/power_save_controller' 
Echo ${AC_UNPLUGGED}            '/sys/module/snd_hda_intel/parameters/power_save'
Echo ${TOUCHSCREEN_AUTOSUSPEND} '/sys/bus/usb/devices/2-3/power/control'
Echo ${AC_PLUGGED}              '/proc/sys/kernel/nmi_watchdog'

for i in /sys/bus/usb/devices/*/power/autosuspend ; do
	Echo ${AC_UNPLUGGED} $i 
done

for i in `ls /sys/class/scsi_host/` ; do
	Echo ${SATA_POWERSAVING} /sys/class/scsi_host/$i/link_power_management_policy
done

for bus in pci i2c usb ; do
	for i in /sys/bus/$bus/devices/*/power/control ; do
		Echo ${PCI_I2C_USB_POWER_CONTROL} $i
	done
done

for i in /sys/bus/usb/devices/*/power/autosuspend ; do
	Echo ${USB_AUTOSUSPEND} $i 
done

if [ $(which iw) ] ; then
	wlancard=$(iw dev | grep Interface | awk '{print $2}')
	iw dev ${wlancard} info > /dev/null
	if [ $? = 0 ] ; then
		iw dev $wlancard set power_save ${WIRELESS_POWERSAVE}
	fi
fi

exit 0