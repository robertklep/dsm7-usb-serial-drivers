---
name: Device not found
about: After loading the modules, /dev/ttyUSB* or /dev/ttyACM* don't exist
title: ''
labels: bug
assignees: robertklep

---

**Type of device**
What type of device (make, model, USB serial chip if you know it) are you trying to add support for? (Please be aware that the modules in the repository are only for USB-to-serial devices, not for Bluetooth, TV receivers, audio interfaces, etc)

**Have the modules loaded?**
Are you sure that the modules you downloaded from this repository have loaded properly? To check, you can run the following commands (after downloading/installing the modules):
```
sudo insmod /lib/modules/usbserial.ko
sudo insmod /lib/modules/ftdi_sio.ko
sudo insmod /lib/modules/cdc-acm.ko
sudo insmod /lib/modules/cp210x.ko
sudo insmod /lib/modules/ch341.ko
sudo insmod /lib/modules/pl2303.ko
```
These commands shouldn't return any errors. If they do, please post them here (unless the error is _"Invalid module format"_, in which case you should [follow the downloading instructions](https://github.com/robertklep/dsm7-usb-serial-drivers#downloading-a-module) carefully).

**Output of lsusb**
Please include the output of the following command:
```
/usr/syno/bin/lsusb -cui
```

```
// PASTE OUTPUT HERE
```
