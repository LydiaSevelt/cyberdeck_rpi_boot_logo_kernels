#!/bin/bash

count=$(ls /boot/kernel_cd_* | wc -l)
num=$(($RANDOM % ${count}))

sed -e "s/kernel=.*/kernel=kernel_cd_${num}.img/" -i /boot/config.txt
