# Zybo Z7-20 Petalinux BSP Project

## Built for Petalinux 2017.4

#### Warning: You should only use this repo when it is checked out on a release tag

## BSP Features

This petalinux project targets the Vivado block diagram project found here: https://github.com/Digilent/Zybo-Z7-20-base-linux.

The project includes the following features by default:

* Ethernet with Unique MAC address and DHCP support (see known issues)
* USB Host support
* UIO drivers for onboard switches, buttons and LEDs
* SSH server
* Build essentials package group for on-board compilation using gcc, etc. 
* HDMI output with kernel mode setting (KMS)
* HDMI input via UIO drivers
* Pcam 5C input via V4L2 drivers 
* U-boot environment variables can be overriden during SD boot by including uEnv.txt
  in the root directory of the SD card (see u-boot documentation).

### Digilent Petalinux Apps 

This project includes the Digilent-apps repository, a set of linux libraries, utilities and demos that are packaged as Petalinux 
apps so they can easily be included with Petalinux projects. These apps add various board specific funtionality, such as controlling
GPIO devices and RGB LEDs from the command line. For complete documentation on these apps, see the repository documentation: 
https://github.com/Digilent/digilent-apps.

## Known Issues

* The console on the attached monitor will shutdown and not resume if left inactive. This can be prevented by running the following at 
  a terminal after boot.
```
echo -e '\033[9;0]' > /dev/tty1
```
* In order to meet timing, the input and output pipelines are clocked at a rate that will only support resolutions with pixel clocks
  of around 133 MHz (potentially slightly more based on horizontal blanking intervals). The output pipeline will automatically reject
  resolutions this high (this is accomplished with a device tree property), however the input pipeline cannot do the same. If a
  resolution with a pixel clock greater than 133 MHz is provided on the input pipeline, then it will overflow and likely stop
  working. Note that 1080@60Hz will still work with this issue, however it is not guaranteed to work on every device due to violation 
  of the input deserializer specifications.
* MACHINE_NAME is currently still set to "template". Not sure the ramifications of changing this, but I don't think our boards
  our supported. For now just leave this as is until we have time to explore the effects of changing this value.
* We have experienced issues with petalinux when it is not installed to /opt/pkg/petalinux/. Digilent highly recommends installing petalinux
  to that location on your system.
* Netboot address and u-boot text address may need to be modified when using initramfs and rootfs is too large. The ramifications of this
  need to be explored and notes should be added to this guide. If this is causing a problem, then u-boot will likely crash or not successfully
  load the kernel. The workaround for now is to use SD rootfs.
* Ethernet PHY reset is not indicated in the device tree. This means it will not be used by the linux and u-boot drivers. This does not
  seem to be causing any known functionality issues. When enabled, ethernet was not functional in Linux. See commented device tree lines
  for how to enable.
* Audio is currently completely non-functional
* To support using the generic UIO driver we have to override the bootargs. This is sloppy, and we should explore modifying our
  demos/libraries to use modprobe to load the uio driver as a module and set the of_id=generic-uio parameter at load time. Then
  we could stop overriding the bootargs in the device tree and also keep the generic uio driver as a module (which is petalinux's
  default) instead of building it into the kernel.

## Quick-Start Guide

This guide will walk you through some basic steps to get you booted into Linux and rebuild the Petalinux project. After completing it, you should refer
to the Petalinux Reference Guide (UG1144) from Xilinx to learn how to do more useful things with the Petalinux toolset. Also, refer to the Known Issues 
section above for a list of problems you may encounter and work arounds.

This guide assumes you are using Ubuntu 16.04.3 LTS. Digilent highly recommends using Ubuntu 16.04.x LTS, as this is what we are most familiar with, and 
cannot guarantee that we will be able to replicate problems you encounter on other Linux distributions.

### Install the Petalinux tools

Digilent has put together this quick installation guide to make the petalinux installation process more convenient. Note it is only tested on Ubuntu 16.04.3 LTS. 

First install the needed dependencies by opening a terminal and running the following:

```
sudo -s
apt-get install tofrodos gawk xvfb git libncurses5-dev tftpd zlib1g-dev zlib1g-dev:i386  \
                libssl-dev flex bison chrpath socat autoconf libtool texinfo gcc-multilib \
                libsdl1.2-dev libglib2.0-dev screen pax 
reboot
```

Next, install and configure the tftp server (this can be skipped if you are not interested in booting via TFTP):

```
sudo -s
apt-get install tftpd-hpa
chmod a+w /var/lib/tftpboot/
reboot
```

Create the petalinux installation directory next:

```
sudo -s
mkdir -p /opt/pkg/petalinux
chown <your_user_name> /opt/pkg/
chgrp <your_user_name> /opt/pkg/
chgrp <your_user_name> /opt/pkg/petalinux/
chown <your_user_name> /opt/pkg/petalinux/
exit
```

Finally, download the petalinux installer from Xilinx and run the following (do not run as root):

```
cd ~/Downloads
./petalinux-v2017.4-final-installer.run /opt/pkg/petalinux
```

Follow the onscreen instructions to complete the installation.

### Source the petalinux tools

Whenever you want to run any petalinux commands, you will need to first start by opening a new terminal and "sourcing" the Petalinux environment settings:

```
source /opt/pkg/petalinux/settings.sh
```

### Download the petalinux project

There are two ways to obtain the project. If you plan on version controlling your project you should clone this repository using the following:

```
git clone --recursive https://github.com/Digilent/Petalinux-Zybo-Z7-20.git
```
If you are not planning on version controlling your project and want a simpler release package, go to https://github.com/Digilent/Petalinux-Zybo-Z7-20/releases/
and download the most recent .bsp file available there for the version of Petalinux you wish to use.


### Generate project

If you have obtained the project source directly from github, then you should simply _cd_ into the Petalinux project directory. If you have downloaded the 
.bsp, then you must first run the following command to create a new project.

```
petalinux-create -t project -s <path to .bsp file>
```

This will create a new petalinux project in your current working directory, which you should then _cd_ into.


### Run the pre-built image from SD

#### Note: The pre-built images are only included with the .bsp release. If you cloned the project source directly, skip this section. 

1. Obtain a microSD card that has its first partition formatted as a FAT filesystem.
2. Copy _pre-built/linux/images/BOOT.BIN_ and _pre-built/linux/images/image.ub_ to the first partition of your SD card.
3. Eject the SD card from your computer and insert it into the Zybo Z7
4. Attach a power source and select it with JP5 (note that using USB for power may not provide sufficient current)
5. If not already done to provide power, attach a microUSB cable between the computer and the Zybo Z7
6. Open a terminal program (such as minicom) and connect to the Zybo Z7 with 115200/8/N/1 settings (and no Hardware flow control). The Zybo Z7 UART typically shows up as /dev/ttyUSB1
7. Optionally attach the Zybo Z7 to a network using ethernet or an HDMI monitor.
8. Press the PS-SRST button to restart the Zybo Z7. You should see the boot process at the terminal and eventually a root prompt.

### Build the petalinux project

Run the following commands to build the petalinux project with the default options:

```
petalinux-build
petalinux-package --boot --force --fsbl images/linux/zynq_fsbl.elf --fpga images/linux/system_wrapper.bit --u-boot
```

### Boot the newly built files from SD 

Follow the same steps as done with the pre-built files, except use the BOOT.BIN and image.ub files found in _images/linux_.

### Configure SD rootfs 

This project is initially configured to have the root file system (rootfs) existing in RAM. This configuration is referred to as "initramfs". A key 
aspect of this configuration is that changes made to the files (for example in your /home/root/ directory) will not persist after the board has been reset. 
This may or may not be desirable functionality.

Another side affect of initramfs is that if the root filesystem becomes too large (which is common if you add many features with "petalinux-config -c rootfs)
 then the system may experience poor performance (due to less available system memory). Also, if the uncompressed rootfs is larger than 128 MB, then booting
 with initramfs will fail unless you make modifications to u-boot (see note at the end of the "Managing Image Size" section of UG1144).

For those that want file modifications to persist through reboots, or that require a large rootfs, the petalinux system can be configured to instead use a 
filesystem that exists on the second partition of the microSD card. This will allow all 512 MiB of memory to be used as system memory, and for changes that 
are made to it to persist in non-volatile storage. To configure the system to use SD rootfs, write the generated root fs to the SD, and then boot the system, 
do the following:

Start by running petalinux-config and setting the following option to "SD":

```
 -> Image Packaging Configuration -> Root filesystem type
```

Next, open project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi in a text editor and locate the "bootargs" line. It should read as follows:

`
		bootargs = "console=ttyPS0,115200 earlyprintk uio_pdrv_genirq.of_id=generic-uio";
`

Replace that line with the following before saving and closing system-user.dtsi:

`
		bootargs = "console=ttyPS0,115200 earlyprintk uio_pdrv_genirq.of_id=generic-uio root=/dev/mmcblk0p2 rw rootwait";
`

#### Note: If you wish to change back to initramfs in the future, you will need to undo this change to the bootargs line.

Then run petalinux-build to build your system. After the build completes, your rootfs image will be at images/linux/rootfs.ext4.

Format an SD card with two partitions: The first should be at least 500 MB and be FAT formatted. The second needs to be at least 1.5 GB (3 GB is preferred) and 
formatted as ext4. The second partition will be overwritten, so don't put anything on it that you don't want to lose. If you are uncertain how to do this in 
Ubuntu, gparted is a well documented tool that can make the process easy.

Copy _images/linux/BOOT.BIN_ and _images/linux/image.ub_ to the first partition of your SD card.

Identify the /dev/ node for the second partition of your SD card using _lsblk_ at the command line. It will likely take the form of /dev/sdX2, where X is 
_a_,_b_,_c_,etc.. Then run the following command to copy the filesystem to the second partition:

#### Warning! If you use the wrong /dev/ node in the following command, you will overwrite your computer's file system. BE CAREFUL

```
sudo umount /dev/sdX2
sudo dd if=images/linux/rootfs.ext4 of=/dev/sdX2
sync
```

The following commands will also stretch the file system so that you can use the additional space of your SD card. Be sure to replace the
block device node as you did above:

```
sudo resize2fs /dev/sdX2
sync
```

#### Note: It is possible to use a third party prebuilt rootfs (such as a Linaro Ubuntu image) instead of the petalinux generated rootfs. To do this, just copy the prebuilt image to the second partition instead of running the "dd" command above. Please direct questions on doing this to the Embedded linux section of the Digilent forum.

Eject the SD card from your computer, then do the following:

1. Insert the microSD into the Zybo Z7
2. Attach a power source and select it with JP5 (note that using USB for power may not provide sufficient current)
3. If not already done to provide power, attach a microUSB cable between the computer and the Zybo Z7
4. Open a terminal program (such as minicom) and connect to the Zybo Z7 with 115200/8/N/1 settings (and no Hardware flow control). The Zybo Z7 UART typically shows up as /dev/ttyUSB1
5. Optionally attach the Zybo Z7 to a network using ethernet or an HDMI monitor.
6. Press the PS-SRST button to restart the Zybo Z7. You should see the boot process at the terminal and eventually a root prompt.

### Prepare for release

This section is only relevant for those who wish to upstream their work or version control their own project correctly on Github.
Note the project should be released configured as initramfs for consistency, unless there is very good reason to release it with SD rootfs.

```
petalinux-package --prebuilt --clean --fpga images/linux/system_wrapper.bit -a images/linux/image.ub:images/image.ub 
petalinux-build -x distclean
petalinux-build -x mrproper
petalinux-package --bsp --force --output ../releases/Petalinux-Zybo-Z7-20-20XX.X-X.bsp -p ./
cd ..
git status # to double-check
git add .
git commit
git push
```
Finally, open a browser and go to github to push your .bsp as a release.

## Using the Pcam 5C

To use the Pcam 5C, run the following from the command line:

```
width=1920
height=1080
rate=15
media-ctl -d /dev/media0 -V '"ov5640 2-003c":0 [fmt:UYVY/'"$width"x"$height"'@1/'"$rate"' field:none]'
media-ctl -d /dev/media0 -V '"43c60000.mipi_csi2_rx_subsystem":0 [fmt:UYVY/'"$width"x"$height"' field:none]'
v4l2-ctl -d /dev/video0 --set-fmt-video=width="$width",height="$height",pixelformat='YUYV'
yavta -c14 -f YUYV -s "$width"x"$height" -F /dev/video0
```

Change the width, height, and rate values depending on the resolution you would like to capture
frames at. Not all resolutions will work, currently tested modes are:

1. 640x480@60Hz
2. 1280x720@30Hz
3. 1920x1080@15Hz

The functions above will create 14 image files in your current directory. To view them,
copy them to your host computer and run the following (you must first install ffmpeg using
apt-get):

```
<Rename the file so it ends in .yuv>
width=1920
height=1080
file=./frame-000000.yuv
out=./frame-000000.png
ffmpeg -s "$width"x"$height" -pix_fmt yuyv422 -i "$file" -y "$out"
```

You will need to replace the width and height to match the resolution the images
were captured at, and the name of the input file and output file (they must end in
.yuv and .png, respectively)

