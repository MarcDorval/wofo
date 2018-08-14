#!/bin/sh

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

# Run with:
#  curl https://raw.githubusercontent.com/MarcDorval/wofo/master/pi/update_1.2.8.sh | sudo sh

echo "Silicon Labs update script for WFx200 WiFi parts"

! grep -q 'NAME="Raspbian GNU/Linux"' /etc/os-release && echo "You must run this script from a Raspberry" && exit 1
[ -z "$SUDO_USER" ] && echo "This script must be run with sudo" && exit 1

set -x

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
	cp -v $SILABS_ROOT/$SILABS_REPO_SCRIPTS/pi/* $USER_ROOT
fi

#   Driver executables
if [ -e "$SILABS_ROOT/$SILABS_REPO_SCRIPTS/wfx_driver" ]; then
	if [ ! -e "$USER_ROOT/wfx_driver" ]; then
		mkdir "$USER_ROOT/wfx_driver"
	fi
	cp -v -r $SILABS_ROOT/$SILABS_REPO_SCRIPTS/wfx_driver/*$DRV_RELEASE*.ko $USER_ROOT/wfx_driver
	WFX_CORE_FILE=$(ls $USER_ROOT/wfx_driver/*$DRV_RELEASE*.ko | grep core)
	WFX_SDIO_FILE=$(ls $USER_ROOT/wfx_driver/*$DRV_RELEASE*.ko | grep sdio)
	WFX_SPI_FILE=$( ls $USER_ROOT/wfx_driver/*$DRV_RELEASE*.ko | grep spi )
	ln -sf $WFX_CORE_FILE /lib/modules/"$KERNEL"/kernel/drivers/net/wireless/siliconlabs/wfx/wfx_core.ko
	ln -sf $WFX_SDIO_FILE /lib/modules/"$KERNEL"/kernel/drivers/net/wireless/siliconlabs/wfx/wfx_wlan_sdio.ko
	ln -sf $WFX_SPI_FILE  /lib/modules/"$KERNEL"/kernel/drivers/net/wireless/siliconlabs/wfx/wfx_wlan_spi.ko
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
	cp -v -r $SILABS_ROOT/$SILABS_REPO_FW/wfx/wfm_wf200_A0.sec $FW_FILE
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
	cp -v -r $SILABS_ROOT/$SILABS_REPO_FW/pds/"$PDS".json $PDS_FILE
	ln -sf $PDS_FILE /lib/firmware/pds_wf200.json
fi

depmod -a

set ""

cd $USER_ROOT
.  $USER_ROOT/wfx_all_checks.sh 
