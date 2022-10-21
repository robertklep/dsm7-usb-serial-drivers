# Missing USB serial drivers for DSM 7 <a href="https://www.paypal.com/donate?hosted_button_id=E7DEFXHFSK8Y6"><img style="vertical-align:middle" src="https://www.paypalobjects.com/en_GB/i/btn/btn_donate_SM.gif"></a>

## Import from Jadahl.com (Oct 2022)

Since the website Jadahl.com, another good source of DSM modules, has been offline for some time and doesn't look like it might be coming back, I retrieved all modules that were posted there (via https://web.archive.org) and added them to this repository. Thank you very much to the person that ran it 😊

### Supported drivers

* `cp210x`
* `ch341`
* `pl2303` (not for all platforms)
* `ti_usb_3410_5052` (not for all platforms)

### Supported platforms

See [the modules/ directory](https://github.com/robertklep/dsm7-usb-serial-drivers/tree/main/modules).

### Installation

NB: the following steps will require SSH access and administrator rights. For the latter, either use `sudo` for each command or use `su` to log in as root.

* The kernel modules for each supported platform can be found in `modules/`. Copy the required files to your Synology and move them to `/lib/modules`
* To get DSM 7 to load the modules at boot time, copy the included file `usb-serial-drivers.sh` to `/usr/local/etc/rc.d`
* Make sure that the file has executable permissions:
  `chmod +x /usr/local/etc/rc.d/usb-serial-drivers.sh`

You don't need to reboot your NAS for the modules to load, just execute the script after you completed the previous steps:
```
# /usr/local/etc/rc.d/usb-serial-drivers.sh start
```

### Building from source

I've built these modules in an Ubuntu 18.04.5 virtual machine on my Synology NAS.

To set up the build environment, I followed the steps [in this document](https://help.synology.com/developer-guide/getting_started/prepare_environment.html). The different NAS targets/platforms can be installed next to each other.

To build the modules for a particular platform, I follow these steps:
```
sudo rm -fr /toolkit/build_env/ds.$platform-7.0/source
sudo /toolkit/pkgscripts-ng/PkgCreate.py -X 1 -P 1 -v 7.0 --min-sdk 7.0 -p $platform $module
cp -v /toolkit/build_env/ds.$platform-7.0/source/$module/*.ko /tmp
```

Replace `$platform` with the NAS platform, for example `apollolake`.
Replace `$module` with the source directory name (found in `sources/` in this repository) relevant for that particular platform. For example, `apollolake` requires the `4.4.x` sources.

Put together, to build for `apollolake`, the commands become:
```
sudo rm -fr /toolkit/build_env/ds.apollolake-7.0/source
sudo /toolkit/pkgscripts-ng/PkgCreate.py -X 1 -P 1 -v 7.0 --min-sdk 7.0 -p apollolake 4.4.x
cp -v /toolkit/build_env/ds.apollolake-7.0/source/$module/*.ko /tmp
```

Due to some concurrency issues that I haven't bothered to look into, the second step (`PkgCreate`) sometimes fails with a compilation error. If that happens, start over.

The last step will copy the driver modules to `/tmp`

### Disclaimer

I don't/can't test every driver. Use at your own peril.

### Attribution

I'm using the source code (as-is) for the drivers included in the Linux kernel from the [Synology Open Source Project](https://sourceforge.net/projects/dsgpl/) and the [Synology Toolchain GPL sources](https://archive.synology.com/download/ToolChain/Synology%20NAS%20GPL%20Source/).
