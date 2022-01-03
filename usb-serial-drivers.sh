#!/bin/sh
case $1 in
  start)
    insmod /lib/modules/usbserial.ko > /dev/null 2>&1
    insmod /lib/modules/ftdi_sio.ko > /dev/null 2>&1
    insmod /lib/modules/cdc-acm.ko > /dev/null 2>&1
    insmod /lib/modules/cp210x.ko > /dev/null 2>&1
    insmod /lib/modules/ch341.ko > /dev/null 2>&1
    insmod /lib/modules/pl2303.ko > /dev/null 2>&1
    insmod /lib/modules/ti_usb_3410_5052.ko > /dev/null 2>&1
    ;;
  stop)
    exit 0
    ;;
  *)
    exit 1
    ;;
esac
