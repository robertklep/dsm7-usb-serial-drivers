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

#### Usage with NodeRed and Docker Compose on NAS

Since many people might use those sensors together with NodeRed and docker, here is a short guide, to getting the USB Serial Device available in NodeRed.

* Make sure to install the driver properly as above mentioned
* You should have the _ttyUSB0_ device available. (can be checked with the command `ls /dev/ttyUSB0`. The response should be `/dev/ttyUSB0`)
* Depending on your user settings, NodeRed needs access to this device. Make sure to set them up to have access to this device. A easy but not recommended and unsecure workarround is to used `chmod 777 /dev/ttyUSB0`.
* In your docker compose file, make sure to pass the ttyUSB0 device: 
  ```
  devices:
    - "/dev/ttyUSB0:/dev/ttyUSB0" 
  ```
* In NodeRed, use some serial node (in this example, the node *node-red-contrib-smartmeter* is being used) and set the settings accordingly to the passed ttyUSB0 device:
  
  ![](/ressources/NodeRed_settings_of_serial_device.png)


Here is my docker compose to get you started:
```
node-red:
  image: nodered/node-red:3.0.2
  environment:
    - TZ=Europe/Amsterdam
  ports:
    - "1880:1880"
  volumes: 
    - /volume1/docker/mystack/nodered:/data
  devices:
    - "/dev/ttyUSB0:/dev/ttyUSB0" #USB to Serial device for Smartmeter (eHZ stromzaehler)
  user: 1026  # < This user needs access to ttyUSB0. solved with chmod 777 quick n dirty
  restart: always
  network_mode: "host" 
```

###### Note: This might not be the best way to do it, but will get you started. Important to note, some steps have to be performed after each reboot. Therefor it is recommendet to add a Task in the Task-Scheduler. Make sure it triggers after each reboot and is being executed as root. Important to node, adapt the second line accordingly to your installed driver.
```
modprobe usbserial
insmod /lib/modules/cp210x.ko > /dev/null 2>&1
chmod 777 /dev/ttyUSB0
```

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
