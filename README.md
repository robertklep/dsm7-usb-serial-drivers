# Missing USB serial drivers for DSM 7 <a href="https://www.paypal.com/donate?hosted_button_id=E7DEFXHFSK8Y6"><img style="vertical-align:middle" src="https://www.paypalobjects.com/en_GB/i/btn/btn_donate_SM.gif"></a>

## Import from Jadahl.com (Oct 2022)

Since the website Jadahl.com, another good source of DSM modules, has been offline for some time and doesn't look like it might be coming back, I retrieved all modules that were posted there (via https://web.archive.org) and added them to this repository. Thank you very much to the person that ran it 😊

### Supported drivers

* `cp210x`
* `ch341`
* `pl2303` (not for all platforms)
* `ti_usb_3410_5052` (not for all platforms)

###### Note: some USB serial devices may already be supported natively by Synology using its USB CDC ACM driver (`/lib/modules/cdc-acm.ko`).
###### Note: this repository is only for USB serial device drivers, it doesn't (and won't) provide drivers for other types of USB devices (TV tuners, Bluetooth, audio, etc). Sorry 🤷🏼‍♂️

### Supported platforms

See [the modules/ directory](https://github.com/robertklep/dsm7-usb-serial-drivers/tree/main/modules).

Drivers for DSM 7.0 are available for most platforms, drivers for DSM 7.2 and 7.2 are slowly being added. If you're missing drivers for a particular platform, please [open an issue](https://github.com/robertklep/dsm7-usb-serial-drivers/issues) and I see what I can do (please also add the kernel version of your platform to your issue, you can find that out with `uname -a` from a terminal).

### Which platform does my Synology use?

Find your Synology model [on this page](https://kb.synology.com/en-uk/DSM/tutorial/What_kind_of_CPU_does_my_NAS_have) and check the "Package Arch" column (second last).

### Downloading a module

Github is a bit confusing if you want to download binary files like this repository provides.

For instance, if you [go to this page](https://github.com/robertklep/dsm7-usb-serial-drivers/tree/main/modules/geminilake/dsm-7.1), the links to the `.ko` files are _not_ download links, they will just bring you to the [information page for that particular file](https://github.com/robertklep/dsm7-usb-serial-drivers/blob/main/modules/geminilake/dsm-7.1/cp210x.ko).

From there, you can download the actual binary module file using the "Download/View raw" link in the bottom square in the page. There's also an explicit download button to the right.

#### Downloading using `wget` or `curl`

If you use a CLI tool like `wget` or `curl` to download the files, you also need the "raw" URL:
```
wget 'https://github.com/robertklep/dsm7-usb-serial-drivers/raw/main/modules/geminilake/dsm-7.1/cp210x.ko'
```
(notice the "raw" in the URL)

### Installation

###### Note: the following steps will require SSH access and administrator rights. For the latter, either use `sudo` for each command or use `su` to log in as root.

* The kernel modules for each supported platform can be found in `modules/`. Copy the required files to your Synology and move them to `/lib/modules`
* To get DSM 7 to load the modules at boot time, copy the included file `usb-serial-drivers.sh` to `/usr/local/etc/rc.d`
* Make sure that the file has executable permissions:
  `chmod +x /usr/local/etc/rc.d/usb-serial-drivers.sh`

You don't need to reboot your NAS for the modules to load, just execute the script after you completed the previous steps:
```
# /usr/local/etc/rc.d/usb-serial-drivers.sh start
```

###### Note: if you don't want to use the script, at least make sure that you load `usbserial.ko` before any of the provided drivers, otherwise you'll get errors.

### Using the devices with Docker (thanks to @tinooo for suggesting this!)

Since many people want to use these serial devices with Docker containers running Home Assistant, Node-RED or Zigbee2MQTT, here's a short guide to explain how to pass a serial device to an application running inside a container.

This assumes that you were able to install the drivers, and that your serial device was recognised. For this, you can use the following command:
```sh
lsusb -cui
```

Your serial device should be shown in the output, including its device assignment. For example, this is what my Conbee II entry looks like:
```
  |__1-3         1cf1:0030:0100 02  2.01   12MBit/s 100mA 2IFs (dresden elektronik ingenieurtechnik GmbH ConBee II DE2427995)
  1-3:1.0         (IF) 02:02:01 1EP  () cdc_acm tty/ttyACM0
```

The numbers aren't relevant, what's relevant is the device assignment: `ttyACM0` (depending on the device, this can also be `ttyUSB0`, and the `0` at the end can also be a diffent number).

For the Docker container to be able to access the serial device, you need to set its permissions correctly. The easiest way to do this:
```sh
sudo chmod 666 /dev/ttyACM0
```

This isn't ideal, and setting those permissions will only last until you unplug the device (or reboot), but alternatives also aren't ideal.

You can set up a task in the Synology Task Scheduler (in the Control Panel) that runs at boot which will load the module(s) you require and sets the correct permissions:
```sh
insmod /lib/modules/cdc-acm.ko
chmod 666 /dev/ttyACM0
```

When the module has loaded and the device has the correct permissions, you can configure a Docker container to use it.

This cannot be done from the GUI that DSM provides for containers, so you need to familiarise yourself with running Docker from the command line.

With the regular `docker` command, use the `--device` argument:
```sh
docker run --device /dev/ttyACM0 ...
```

If you use `docker-compose` (recommended) you add the following to the compose file (typically called `compose.yaml` or `compose.yml`):
```yaml
devices:
  - "/dev/ttyACM0:/dev/ttyACM0" 
```
More information [here](https://docs.docker.com/compose/compose-file/compose-file-v3/#devices).

When you start the container, the serial device should now be accessible as `/dev/ttyACM0`

See the various projects' documentation for more information:
* [Zigbee2MQTT](https://www.zigbee2mqtt.io/guide/installation/02_docker.html#docker-compose)
* [Node-RED](https://nodered.org/docs/getting-started/docker#accessing-host-devices)
* [Home Assistant](https://www.home-assistant.io/installation/linux#exposing-devices)

### Building from source

I've built these modules in an Ubuntu 18.04.5 virtual machine on my Synology NAS.

To set up the build environment, I followed the steps [in this document](https://help.synology.com/developer-guide/getting_started/prepare_environment.html). The different NAS targets/platforms can be installed next to each other.

To build the modules for a particular platform, I follow these steps:
```
sudo rm -fr /toolkit/build_env/ds.$platform-7.0/source
sudo /toolkit/pkgscripts-ng/PkgCreate.py -X 0 -P 1 -v 7.0 --min-sdk 7.0 -p $platform $module
cp -v /toolkit/build_env/ds.$platform-7.0/source/$module/*.ko /tmp
```

Replace `$platform` with the NAS platform, for example `apollolake`.
Replace `$module` with the source directory name (found in `sources/` in this repository) relevant for that particular platform. For example, `apollolake` requires the `4.4.x` sources.

Put together, to build for `apollolake`, the commands become:
```
sudo rm -fr /toolkit/build_env/ds.apollolake-7.0/source
sudo /toolkit/pkgscripts-ng/PkgCreate.py -X 0 -P 1 -v 7.0 --min-sdk 7.0 -p apollolake 4.4.x
cp -v /toolkit/build_env/ds.apollolake-7.0/source/$module/*.ko /tmp
```

Due to some concurrency issues that I haven't bothered to look into, the second step (`PkgCreate`) sometimes fails with a compilation error. If that happens, start over.

The last step will copy the driver modules to `/tmp`

### Disclaimer

I don't/can't test every driver. Use at your own peril.

### Attribution

I'm using the source code (as-is) for the drivers included in the Linux kernel from the [Synology Open Source Project](https://sourceforge.net/projects/dsgpl/) and the [Synology Toolchain GPL sources](https://archive.synology.com/download/ToolChain/Synology%20NAS%20GPL%20Source/).
