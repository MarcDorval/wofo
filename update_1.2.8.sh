#!/bin/sh

# Run with:
#  curl https://raw.githubusercontent.com/MarcDorval/wofo/master/update_1.2.8.sh | sudo sh

START_DIR=$(pwd)
SILABS_ROOT=/usr/src/siliconlabs
USER_ROOT=/home/pi

SCRIPTS_TAG=1.2.8
DRV_RELEASE=1.2.8
FW_RELEASE=1.2.8
DRV_TAG=DRV"$DRV_RELEASE"
FW_TAG=FW"$FW_RELEASE"
PDS=pds_BRD802xA
KERNEL=$(uname -r)

SILABS_GITHUB_SCRIPTS=https://github.com/MarcDorval
SILABS_REPO_SCRIPTS=wofo

SILABS_GITHUB_FW=https://github.com/SiliconLabs
SILABS_REPO_FW=wfx_firmware

SILABS_GITHUB_DRV=https://github.com/SiliconLabs
SILABS_REPO_DRV=wfx_linux_driver_code

echo "Silicon Labs update script for WFx200 WiFi parts"

! grep -q 'NAME="Raspbian GNU/Linux"' /etc/os-release && echo "You must run this script from a Raspberry" && exit 1
[ -z "$SUDO_USER" ] && echo "This script must be run with sudo" && exit 1

#set -x

if [ ! -e "$SILABS_ROOT" ]; then
	sudo mkdir "$SILABS_ROOT"
fi

####################################################################################################
# Retrieving and copying Scripts and Driver executables
cd "$SILABS_ROOT"

#   Scripts
if [ ! -e "$SILABS_ROOT/$SILABS_REPO_SCRIPTS" ]; then
	echo "Cloning $SILABS_GITHUB_SCRIPTS/$SILABS_REPO_SCRIPTS.git in $(pwd)"
	sudo git clone $SILABS_GITHUB_SCRIPTS/$SILABS_REPO_SCRIPTS.git --depth 5
fi

cd "$SILABS_ROOT/$SILABS_REPO_SCRIPTS"
echo "Fetching $SILABS_GITHUB_SCRIPTS/$SILABS_REPO_SCRIPTS.git tag $SCRIPTS_TAG in $(pwd)"
sudo git fetch $SILABS_GITHUB_SCRIPTS/$SILABS_REPO_SCRIPTS.git --depth 5 --tags "$SCRIPTS_TAG"

if [ -e "$SILABS_ROOT/$SILABS_REPO_SCRIPTS/pi" ]; then
	echo "Copying Silicon Labs scripts in $USER_ROOT"
	cp -v $SILABS_ROOT/$SILABS_REPO_SCRIPTS/pi/* $USER_ROOT
fi
sudo chown pi: $USER_ROOT/*.sh
chmod a+x $USER_ROOT/*.sh

#   Driver executables
if [ -e "$SILABS_ROOT/$SILABS_REPO_SCRIPTS/wfx_driver" ]; then
	if [ ! -e "$USER_ROOT/wfx_driver" ]; then
		mkdir "$USER_ROOT/wfx_driver"
	fi
	echo "Copying Silicon Labs WFx200 Drivers in $USER_ROOT/wfx_driver"
	cp -v -r $SILABS_ROOT/$SILABS_REPO_SCRIPTS/wfx_driver/*$DRV_RELEASE*.ko $USER_ROOT/wfx_driver
	WFX_CORE_FILE=$(ls $USER_ROOT/wfx_driver/*$DRV_RELEASE_wfx_core.ko     )
	WFX_SDIO_FILE=$(ls $USER_ROOT/wfx_driver/*$DRV_RELEASE_wfx_wlan_sdio.ko)
	WFX_SPI_FILE=$( ls $USER_ROOT/wfx_driver/*$DRV_RELEASE_wfx_wlan_spi.ko )
	echo "Creating symbolic links to Silicon Labs WFx200 Drivers"
	set -x
	ln -sf $WFX_CORE_FILE /lib/modules/"$KERNEL"/kernel/drivers/net/wireless/siliconlabs/wfx/wfx_core.ko
	ln -sf $WFX_SDIO_FILE /lib/modules/"$KERNEL"/kernel/drivers/net/wireless/siliconlabs/wfx/wfx_wlan_sdio.ko
	ln -sf $WFX_SPI_FILE  /lib/modules/"$KERNEL"/kernel/drivers/net/wireless/siliconlabs/wfx/wfx_wlan_spi.ko
	set ""
fi
####################################################################################################
# Retrieving and copying FW & PDS files
cd "$SILABS_ROOT"

if [ ! -e "$SILABS_ROOT/$SILABS_REPO_FW" ]; then
	echo "Cloning $SILABS_GITHUB_FW/$SILABS_REPO_FW.git in $(pwd)"
	sudo git clone $SILABS_GITHUB_FW/$SILABS_REPO_FW.git --depth 5
fi

cd "$SILABS_ROOT/$SILABS_REPO_FW"
echo "Fetching $SILABS_GITHUB_FW/$SILABS_REPO_FW.git tag $FW_TAG in $(pwd)"
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
	cp -v -r $SILABS_ROOT/$SILABS_REPO_FW/wfx/wfm_wf200_A0.sec $FW_FILE
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
	cp -v -r $SILABS_ROOT/$SILABS_REPO_FW/pds/"$PDS".json $PDS_FILE
	echo "Creating symbolic link to Silicon Labs WFx200 PDS"
	ln -sf $PDS_FILE /lib/firmware/pds_wf200.json
fi

echo "Updating modules dependencies"
depmod -a

set ""

cd $START_DIR
