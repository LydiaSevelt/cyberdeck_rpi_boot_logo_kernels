#!/bin/bash

# $1 = raspberry pi version
# $2 = (optional) text to append onto kernel version

help() {
	echo "Script takes two options, the rpi version and an optional string to append onto the kernel version"
	echo "Options are rpi0, rpi1, rpi2, rpi3, or rpi4"
	echo "Optional: string to be appended onto kernel version"
	echo "Examples:"
	echo "  sudo ./build_kernels.sh rpi4"
	echo "  sudo ./build_kernels.sh rpi4 deck"
	exit 0
}

if [ "$(whoami)" != "root" ]; then
	echo "Must be run as root, did you run with sudo?"
	echo ""
	help
fi

if [ "${1}" == "rpi0" ]; then
	KERNEL_VER="kernel"
	CONFIG="bcmrpi_defconfig"
	CORES="1"
elif [ "${1}" == "rpi1" ]; then
	KERNEL_VER="kernel"
	CONFIG="bcmrpi_defconfig"
	CORES="4"
elif [ "${1}" == "rpi2" ]; then
	KERNEL_VER="kernel7"
	CONFIG="bcm2709_defconfig"
	CORES="4"
elif [ "${1}" == "rpi3" ]; then
	KERNEL_VER="kernel7"
	CONFIG="bcm2709_defconfig"
	CORES="4"
elif [ "${1}" == "rpi4" ]; then
	KERNEL_VER="kernel7l"
	CONFIG="bcm2711_defconfig"
	CORES="4"
else
	help
fi

# install needed utilities
apt install git bc bison flex libssl-dev make

# make a backup of the boot config
cp /boot/config.txt /boot/config.txt.bk

# pull source repo
git clone --depth=1 https://github.com/raspberrypi/linux

cd linux
# loop through all of the 
COUNT=0
for deck_logo in $(ls ../deck_logos/*.ppm); do
	# copy logo into place
	cp $deck_logo drivers/video/logo/logo_linux_clut224.ppm
	
	if [ "${COUNT}" == "0" ]; then
		# and make the config
		KERNEL=${KERNEL_VER} make ${CONFIG}
	
		# if $2 was provided appened it onto the localverion of the kernel adding a dash before the provide string and with the quotes
		if [ "${2}" != "" ]; then
			sed -e "s/\(CONFIG_LOCALVERSION=\".*[^\"]\)/\1-${2}/" -i .config
		fi
		
		# build the kernel, modules and dtbs
		make -j4 zImage modules dtbs
	else
		# build just the kernel
		make -j4 zImage
	fi		
	
	if [ "${COUNT}" == "0" ]; then
		# install the modules
		make modules_install
		
		# copy files into place
		cp arch/arm/boot/dts/*.dtb /boot/
		cp arch/arm/boot/dts/overlays/*.dtb* /boot/overlays/
		cp arch/arm/boot/dts/overlays/README /boot/overlays/
	fi
	
	cp arch/arm/boot/zImage /boot/KERNEL_cd_${COUNT}.img
	
	COUNT=$((${COUNT}+1))
done

# back up into the main directory
cd ../

# copy logo_rand script into place
cp ./logo_rand.sh /boot/

# add kernel line
cat /boot/config.txt | grep "^kernel=" > /dev/null
if [ "$?" == "0" ]; then
	# kernel line already exists
	sed -e 's/kernel=.*$/kernel=kernel_cd_0.img/' -i /boot/config.txt
else
	# add kernel line to end of config.txt
	echo "kernel=kernel_cd_0.img" >> /boot/config.txt
fi

# add randomize script to rc.local
cat /etc/rc.local | grep logo_rand.sh > /dev/null
if [ "$?" != "0" ]; then
	# logo_rand.sh not in rc.local, add it above the exit call
	sed -e '$i/boot/logo_rand.sh' -i /etc/rc.local
fi

