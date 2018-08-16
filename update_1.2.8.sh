#!/bin/sh

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
PDS=pds_BRD802xA
KERNEL=$(uname -r)

CONFIG_FILE=/boot/config.txt
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

! grep -q 'NAME="Raspbian GNU/Linux"' /etc/os-release && echo "You must run this script from a Raspberry" && exit 1
[ -z "$SUDO_USER" ] && echo "This script must be run with sudo" && exit 1

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

# Checking current overlays and blacklist. Configuring for SDIO auto by default
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
OVERLAYS=$(cat "$CONFIG_FILE" | grep ^dtoverlay | grep -E "sdio|spi")
if [ -z "$OVERLAYS" ]; then
	echo "No SDIO or SPI Overlay enabled. Enabling SDIO and commenting SPI by default"
	echo "dtoverlay=sdio"       >> "$CONFIG_FILE"
	echo "#dtoverlay=wfx-spi"   >> "$CONFIG_FILE"
fi

echo "Use the following scripts to configure WiFi for your use case"
ls $USER_ROOT/*.sh | grep -E "_auto|_modprobe"
echo " Then enter 'sudo halt',"
echo "   wait for the activity leds to stop blinking,"
echo "   set the Devkit switch to SDIO or SPI according to your configuration"
echo "   and power-cycle the Pi to get started with your Wfx200"

echo " Once rebooted, use the /home/pi/wfx_all_checks.sh script to check your setup and how the startup is going"
