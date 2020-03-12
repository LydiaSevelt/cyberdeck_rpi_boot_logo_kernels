# cyberdeck_rpi_boot_logo_kernels  
Raspbian image kernels built with cyberdeck logos  

This is for a stock Raspbian Buster image, version 4.19.108-v7+  
Almost no testing has been done at this time, satisfaction not guaranteed.

# Using the install script

**!!Warning!!**- This script is barely tested and has almost no error checking, essentially it just runs all of the commands in the manual install instructions below without doing error checking.  
You probably want to fully update your raspbian image before running this.  
After running this a future kernel update will likely break things, beware.  

1. Mount your SD card on a machine to a path, example path /mnt  
Also mount the boot partition to /mnt/boot

2. From inside the repository directory run the install script and provide the path to where you mounted the SD card  
`./install_kernels.sh /mnt/`  

That should be it!

# Manual install instructions  

1. Mount your SD card on a machine to a path, example path /mnt  
Also mount the boot partition to /mnt/boot

2. Copy the kernels or kernel you wish to use to boot  
`cp ~/cyberdeck_rpi_boot_logo_kernels/kernel_cd_* /mnt/boot/`

3. Backup previous version of firmware that need to be updated  
`mv /mnt/boot/bootcode.bin /mnt/boot/bootcode.bin.bk`  
`mv /mnt/boot/fixup.dat /mnt/boot/fixup.dat.bk`  
`mv /mnt/boot/start.elf /mnt/boot/start.elf.bk`  
`mv /mnt/opt/vc /mnt/opt/vc.bk`  

4. Copy new versions of firmware into place  
`cp ~/cyberdeck_rpi_boot_logo_kernels/boot/bootcode.bin /mnt/boot/`  
`cp ~/cyberdeck_rpi_boot_logo_kernels/boot/fixup.dat /mnt/boot/`  
`cp ~/cyberdeck_rpi_boot_logo_kernels/boot/start.elf /mnt/boot/`  
`cp -R ~/cyberdeck_rpi_boot_logo_kernels/vc /mnt/opt/`  

5. Uncompress modules for the 4.19.108-v7+ into the lib/modules directory  
`tar -zcxf ~/cyberdeck_rpi_boot_logo_kernels/modules.tar.gz -C /mnt/lib/`  

6. Copy the logo_rand script into place if you want to randomize the boot logo  
`cp ~/cyberdeck_rpi_boot_logo_kernels/logo_rand.sh /mnt/boot/`  

7. Fix the permissons on everything in case it's not owned by root:root  
`chown root:root /mnt/boot/kernel_cd_*`  
`chown root:root /mnt/boot/bootcode.bin`  
`chown root:root /mnt/boot/fixup.dat`  
`chown root:root /mnt/boot/start.elf`  
`chown root:root /mnt/boot/logo_rand.sh`  
`chown -R root:root /mnt/opt/vc/`  
`chown -R root:root /mnt/lib/modules/4.19.108*`  

8. Add kernel= line to config.txt to select kernel to boot  
See reference below for color mapping if not randomizing  
`echo "kernel=kernel_cd_0.img" >> /mnt/boot/config.txt`  

9. Set the logo_rand.sh script to run with rc.local if you want to randomize boot kernel  
Be sure to insert it before the exit 0 at the end of the script  
The provided sed command inserts at the second to last line  
`sed -e '$i/boot/logo_rand.sh' /mnt/etc/rc.local` 

# Color mapping for provided kernels

cyberdeck_orange_multi_clean -> kernel_cd_0.img  
cyberdeck_cyan_multi_clean -> kernel_cd_1.img  
cyberdeck_green_multi_clean -> kernel_cd_2.img  
cyberdeck_purple_multi_clean -> kernel_cd_3.img  
cyberdeck_yellow_multi_clean -> kernel_cd_4.img  
