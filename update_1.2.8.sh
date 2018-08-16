#!/bin/bash

# Run with:
#  curl https://raw.githubusercontent.com/MarcDorval/wofo/master/update_1.2.8.sh | sudo sh

START_DIR=$(pwd)
SILABS_ROOT=/usr/src/siliconlabs
USER_ROOT=/home/pi

SCRIPTS_TAG=1.2.8
DRV_RELEASE=1.2.8
FW_RELEASE=1.2.8
DRV_TAG=DRV-"$DRV_RELEASE"
FW_TAG=FW"$FW_RELEASE"
PDS="pds_BRD802xA"
KERNEL_ARRAY=(4.4.50-v7+)
KERNEL=$(uname -r)
KERNEL_IMAGE=kernel7_"$KERNEL".img
DEVICE_TREE_BLOB=bcm2710-rpi-3-b_4.4.50-v7+.dtb

CONFIG_FILE=config.txt
BLACKLIST_FILE=/etc/modprobe.d/raspi-blacklist.conf

SILABS_GITHUB_SCRIPTS=https://github.com/MarcDorval
SILABS_REPO_SCRIPTS=wofo

SILABS_GITHUB_FW=https://github.com/SiliconLabs
SILABS_REPO_FW=wfx_firmware

SILABS_GITHUB_DRV=https://github.com/SiliconLabs
SILABS_REPO_DRV=wfx_linux_driver_code

echo "Silicon Labs update script for WFx200 WiFi parts"
echo "  Driver $DRV_TAG"
echo "  FW     $FW_TAG"
echo "  PDS    $PDS"
echo "  KERNEL $KERNEL"

####################################################################################################
# Execution context checks:
#  The platform is a Raspberry Pi
! grep -q 'NAME="Raspbian GNU/Linux"' /etc/os-release && echo "You must run this script from a Raspberry" && exit 1
#  Executed as sudo
[ -z "$SUDO_USER" ] && echo "\nThis script must be run with sudo" && exit 1
#  The kernel release is supported
KERNEL_SUPPORTED=0
for k in "${KERNEL_ARRAY[@]}"; do
	echo "$k "
    if [ "$KERNEL" == "$k" ]; then
		KERNEL_SUPPORTED=1
		echo "KERNEL_SUPPORTED $KERNEL_SUPPORTED "
		break
	fi
done
if [ "$KERNEL_SUPPORTED" == 0 ]; then
	echo "kernel '$KERNEL' is not supported, sorry. Only supporting ${KERNEL_ARRAY[@]}"
	exit 1
fi


####################################################################################################
# Creating work folder
if [ ! -e "$SILABS_ROOT" ]; then
	sudo mkdir "$SILABS_ROOT"
fi

####################################################################################################
# Retrieving and copying Scripts and Driver executables
cd "$SILABS_ROOT"

#   Scripts
if [ ! -e "$SILABS_ROOT/$SILABS_REPO_SCRIPTS" ]; then
	echo "Cloning repository $SILABS_GITHUB_SCRIPTS/$SILABS_REPO_SCRIPTS.git in $(pwd)"
	sudo git clone $SILABS_GITHUB_SCRIPTS/$SILABS_REPO_SCRIPTS.git --depth 5
fi

cd "$SILABS_ROOT/$SILABS_REPO_SCRIPTS"
echo "Fetching repository $SILABS_GITHUB_SCRIPTS/$SILABS_REPO_SCRIPTS.git tag $SCRIPTS_TAG in $(pwd)"
sudo git fetch $SILABS_GITHUB_SCRIPTS/$SILABS_REPO_SCRIPTS.git --depth 5 --tags "$SCRIPTS_TAG"

if [ -e "$SILABS_ROOT/$SILABS_REPO_SCRIPTS/pi" ]; then
	echo "Copying Silicon Labs scripts in $USER_ROOT"
	cp --force $SILABS_ROOT/$SILABS_REPO_SCRIPTS/pi/* $USER_ROOT
fi
sudo chown pi: $USER_ROOT/*.sh
chmod a+x $USER_ROOT/*.sh

#   Driver executables
if [ -e "$SILABS_ROOT/$SILABS_REPO_SCRIPTS/wfx_driver" ]; then
	if [ ! -e "$USER_ROOT/wfx_driver" ]; then
		mkdir "$USER_ROOT/wfx_driver"
	fi
	echo "Copying Silicon Labs WFx200 Drivers in $USER_ROOT/wfx_driver"
	cp --force $SILABS_ROOT/$SILABS_REPO_SCRIPTS/wfx_driver/*$DRV_RELEASE*wfx*.ko $USER_ROOT/wfx_driver
	WFX_CORE_FILE=$(ls $USER_ROOT/wfx_driver/*wfx_core.ko      | grep $DRV_TAG)
	echo "WFX_CORE_FILE=$WFX_CORE_FILE"
	WFX_SDIO_FILE=$(ls $USER_ROOT/wfx_driver/*wfx_wlan_sdio.ko | grep $DRV_TAG)
	echo "WFX_CORE_FILE=$WFX_CORE_FILE"
	WFX_SPI_FILE=$( ls $USER_ROOT/wfx_driver/*wfx_wlan_spi.ko  | grep $DRV_TAG)
	echo "WFX_CORE_FILE=$WFX_CORE_FILE"
	echo "Creating symbolic links to Silicon Labs WFx200 Drivers"
	ln -sf $WFX_CORE_FILE /lib/modules/$KERNEL/kernel/drivers/net/wireless/siliconlabs/wfx/wfx_core.ko
	ln -sf $WFX_SDIO_FILE /lib/modules/$KERNEL/kernel/drivers/net/wireless/siliconlabs/wfx/wfx_wlan_sdio.ko
	ln -sf $WFX_SPI_FILE  /lib/modules/"$KERNEL"/kernel/drivers/net/wireless/siliconlabs/wfx/wfx_wlan_spi.ko
fi
####################################################################################################
# Retrieving and copying FW & PDS files
cd "$SILABS_ROOT"

if [ ! -e "$SILABS_ROOT/$SILABS_REPO_FW" ]; then
	echo "Cloning repository $SILABS_GITHUB_FW/$SILABS_REPO_FW.git in $(pwd)"
	sudo git clone $SILABS_GITHUB_FW/$SILABS_REPO_FW.git --depth 5
fi

cd "$SILABS_ROOT/$SILABS_REPO_FW"
echo "Fetching repository $SILABS_GITHUB_FW/$SILABS_REPO_FW.git tag $FW_TAG in $(pwd)"
sudo git fetch $SILABS_GITHUB_FW/$SILABS_REPO_FW.git --depth 5 --tags "$FW_TAG"

#   FW files
if [ -e "$SILABS_ROOT/$SILABS_REPO_FW/wfx" ]; then
	if [ ! -e "$USER_ROOT/wfx_firmware" ]; then
		mkdir "$USER_ROOT/wfx_firmware"
	fi
	if [ ! -e "$USER_ROOT/wfx_firmware/wfx" ]; then
		mkdir "$USER_ROOT/wfx_firmware/wfx"
	fi
	FW_FILE=$USER_ROOT/wfx_firmware/wfx/wfm_wf200_A0_FW"$FW_RELEASE".sec
	echo "Copying Silicon Labs WFx200 Firmware in $USER_ROOT/wfx_firmware/wfx"
	cp --force $SILABS_ROOT/$SILABS_REPO_FW/wfx/wfm_wf200_A0.sec $FW_FILE
	echo "Creating symbolic link to Silicon Labs WFx200 Firmware"
	ln -sf $FW_FILE /lib/firmware/wfm_wf200.sec
fi
#   PDS files
if [ -e "$SILABS_ROOT/$SILABS_REPO_FW/pds" ]; then
	if [ ! -e "$USER_ROOT/wfx_firmware" ]; then
		mkdir "$USER_ROOT/wfx_firmware"
	fi
	if [ ! -e "$USER_ROOT/wfx_firmware/pds" ]; then
		mkdir "$USER_ROOT/wfx_firmware/pds"
	fi
	PDS_FILE=$USER_ROOT/wfx_firmware/pds/"$PDS"_FW"$FW_RELEASE".json
	echo "Copying Silicon Labs WFx200 PDS file in $USER_ROOT/wfx_firmware/pds"
	cp --force $SILABS_ROOT/$SILABS_REPO_FW/pds/"$PDS".json $PDS_FILE
	echo "Creating symbolic link to Silicon Labs WFx200 PDS"
	ln -sf $PDS_FILE /lib/firmware/pds_wf200.json
fi

# Updating modules dependencies
echo "Updating modules dependencies"
depmod -a

set ""

cd $START_DIR

# Checking kernel image, dtb and config files presence. Adding them is not present
if [ ! -e "/boot/$KERNEL_IMAGE" ]; then
	echo "No /boot/$KERNEL_IMAGE file. Copying it"
	cp --force "$SILABS_ROOT/$SILABS_REPO_SCRIPTS/boot/$KERNEL_IMAGE" "/boot/$KERNEL_IMAGE"
fi
if [ ! -e "/boot/$DEVICE_TREE_BLOB" ]; then
	echo "No /boot/$DEVICE_TREE_BLOB file. Copying it"
	cp --force "$SILABS_ROOT/$SILABS_REPO_SCRIPTS/boot/$DEVICE_TREE_BLOB" "/boot/$DEVICE_TREE_BLOB"
fi
# Checking current kernel selection
KERNEL_SELECTED=$(cat /boot/$CONFIG_FILE | grep ^kernel | cut -d "=" -f 2)
if [ "$KERNEL_SELECTED" != "$KERNEL_IMAGE" ]; then
	if [ -z "$KERNEL_SELECTED" ]; then
		echo "No kernel image selected in /boot/$CONFIG_FILE. Selecting $KERNEL_IMAGE by default"
		echo "kernel=$KERNEL_IMAGE"   >> "/boot/$CONFIG_FILE"
	else
		sed -i~ 's/$KERNEL_SELECTED/$KERNEL_IMAGE/m' "/boot/$CONFIG_FILE"
	fi
fi
# Checking current device tree selection
DEVICE_TREE_SELECTED=$(cat /boot/$CONFIG_FILE | grep ^device_tree | cut -d "=" -f 2)
if [ "$DEVICE_TREE_SELECTED" != "$DEVICE_TREE_BLOB" ]; then
	if [ -z "$DEVICE_TREE_SELECTED" ]; then
		echo "No device tree selected in /boot/$CONFIG_FILE. Selecting $DEVICE_TREE_BLOB"
		echo "DEVICE_TREE=$DEVICE_TREE_BLOB"   >> "/boot/$CONFIG_FILE"
	else
		echo "Incorrect device tree selected in /boot/$CONFIG_FILE. Selecting $DEVICE_TREE_BLOB"
		sed -i~ 's/$DEVICE_TREE_SELECTED/$DEVICE_TREE_BLOB/m' "/boot/$CONFIG_FILE"
	fi
fi
# Checking current overlays and blacklist (Configuring for SDIO auto by default)
BLACKLISTED=$(cat "$BLACKLIST_FILE" | grep ^blacklist | grep -E "brcmfmac")
if [ -z "$BLACKLISTED" ]; then
	echo "Broadcom WiFi not blacklisted. Blacklisting it by default (for Pi3)"
	echo "blacklist brcmfmac" >> "$BLACKLIST_FILE"
fi
BLACKLISTED=$(cat "$BLACKLIST_FILE" | grep ^blacklist | grep -E "sdio|spi")
if [ -z "$BLACKLISTED" ]; then
	echo "No SDIO or SPI Driver blacklisted. Blacklisting SPI and commenting SDIO by default"
	echo "#blacklist wfx_wlan_sdio" >> "$BLACKLIST_FILE"
	echo "blacklist wfx_wlan_spi"   >> "$BLACKLIST_FILE"
fi
OVERLAYS=$(cat "/boot/$CONFIG_FILE" | grep ^dtoverlay | grep -E "sdio|spi")
if [ -z "$OVERLAYS" ]; then
	echo "No SDIO or SPI Overlay enabled. Enabling SDIO and commenting SPI by default"
	echo "dtoverlay=sdio"       >> "/boot/$CONFIG_FILE"
	echo "#dtoverlay=wfx-spi"   >> "/boot/$CONFIG_FILE"
fi
# Displaying user information
echo "Use the following scripts to configure WiFi for your use case"
ls $USER_ROOT/*.sh | grep -E "_auto|_modprobe"
echo " Then enter 'sudo halt',"
echo "   wait for the activity leds to stop blinking,"
echo "   set the Devkit switch to SDIO or SPI according to your configuration"
echo "   and power-cycle the Pi to get started with your Wfx200"

echo " Once rebooted, use the /home/pi/wfx_all_checks.sh script to check your setup and how the startup is going"
