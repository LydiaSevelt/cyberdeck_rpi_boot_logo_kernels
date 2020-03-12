#!/bin/bash

# $1 path to mount with both raspbian filesystem and boot mounted.

INS_PATH=${1}

if [ ! -d ${INS_PATH} ]; then
	echo "Provided path not a directory."
	exit 1
fi

if [ ! -d ${INS_PATH}"/opt" ]; then
	echo "Cannot fine opt, did you provide the correct path to the mounted SD card?"
	exit 2
fi

if [ ! -f ${INS_PATH}"/boot/config.txt" ]; then
	echo "Cannot find config.txt, did you mount boot also?"
	exit 3
fi

# assuming everthing is ok now, good luck.

# copy kernels into place
cp ./kernel_cd_* ${INS_PATH}/boot/

# backup old firmware files
mv ${INS_PATH}/boot/bootcode.bin ${INS_PATH}/boot/bootcode.bin.bk
mv ${INS_PATH}/boot/fixup.dat ${INS_PATH}/boot/fixup.dat.bk
mv ${INS_PATH}/boot/start.elf ${INS_PATH}/boot/start.elf.bk
mv ${INS_PATH}/opt/vc ${INS_PATH}/opt/vc.bk

# copy new firmware files
cp ./boot/bootcode.bin ${INS_PATH}/boot/
cp ./boot/fixup.dat ${INS_PATH}/boot/
cp ./boot/start.elf ${INS_PATH}/boot/
cp -R ./vc ${INS_PATH}/opt/

# extract modules into /lib/modules
tar -zxvf ./modules.tar.gz -C ${INS_PATH}/lib/

# copy randomize script
cp ./logo_rand.sh ${INS_PATH}/boot/

# fix permissions in case they need fixing
chown root:root ${INS_PATH}/boot/kernel_cd_*
chown root:root ${INS_PATH}/boot/bootcode.bin
chown root:root ${INS_PATH}/boot/fixup.dat
chown root:root ${INS_PATH}/boot/start.elf
chown root:root ${INS_PATH}/boot/logo_rand.sh
chown -R root:root ${INS_PATH}/opt/vc/
chown -R root:root ${INS_PATH}/lib/modules/4.19.108*

# add kernel line
echo "kernel=kernel_cd_0.img" >> ${INS_PATH}/boot/config.txt

# add randomize script to rc.local
sed -e '$i/boot/logo_rand.sh' -i ${INS_PATH}/etc/rc.local


