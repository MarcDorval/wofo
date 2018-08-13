#!/bin/bash
# Checks the overlay and blacklist status for WFX SDIO and SPI
# If first  argument provided, stores the results in arrays with a corresponding index
# If second argument provided, compares the results with arrays with the second index
#    and sets
#        number of changes
#        config message (to be displayed if needed)

if [ -n "$1" ]; then
	i=$1
else
	i=0
fi

# Check which overlays are enabled
conf_sdio[$i]=$(cat /boot/config.txt  | grep -v ^# | grep -v ^$ | grep overlay | grep "sdio")
conf_spi[$i]=$( cat /boot/config.txt  | grep -v ^# | grep -v ^$ | grep overlay | grep "spi" )
if [ -n "${conf_sdio[$i]}" ]; then
	echo ${conf_sdio[$i]}
fi
if [ -n "${conf_spi[$i]}" ]; then
	echo ${conf_spi[$i]}
fi
# Check which drivers are blacklisted
blck_sdio[$i]=$(cat /etc/modprobe.d/raspi-blacklist.conf | grep -v ^# | grep -v ^$ | grep wfx_wlan_sdio)
blck_spi[$i]=$( cat /etc/modprobe.d/raspi-blacklist.conf | grep -v ^# | grep -v ^$ | grep wfx_wlan_spi )
if [ -n "${blck_sdio[$i]}" ]; then
	echo ${blck_sdio[$i]}
fi
if [ -n "${blck_spi[$i]}" ]; then
	echo ${blck_spi[$i]}
fi

config_changes=0
config_message=""

if [ -n "$2" ]; then
	if [ "${conf_sdio[$1]}" != "${conf_sdio[$2]}" ]; then
		config_changes=$(($config_changes+1))
	fi
	if [ "${conf_spi[$1]}" != "${conf_spi[$2]}" ]; then
		config_changes=$(($config_changes+1))
	fi
	if [ "${blck_sdio[$1]}" != "${blck_sdio[$2]}" ]; then
		config_changes=$(($config_changes+1))
	fi
	if [ "${blck_spi[$1]}" != "${blck_spi[$2]}" ]; then
		config_changes=$(($config_changes+1))
	fi
	if [ "$config_changes" != 0 ]; then
		config_message="use 'sudo halt' (wait for the led to stop blinking) and then power-cycle the Pi, since you changed the configuration"
	fi
fi
