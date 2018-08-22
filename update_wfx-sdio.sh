#!/bin/bash

# Run with:
#  curl https://raw.githubusercontent.com/MarcDorval/wofo/master/update_wfx-sdio.sh | sudo bash

START_DIR=$(pwd)
SILABS_ROOT=/usr/src/siliconlabs
USER_ROOT=/home/pi

UPDATE_TAG="wfx-sdio"
SCRIPTS_TAG="wfx-sdio"
DRV_RELEASE=1.2.8
FW_RELEASE=1.2.8
DRV_TAG=DRV-"$DRV_RELEASE"
FW_TAG=FW"$FW_RELEASE"
PDS=pds_BRD802xA
KERNEL_ARRAY=(4.4.50-v7+)
KERNEL=$(uname -r)
KERNEL_IMAGE=kernel7_"$KERNEL".img
DEVICE_TREE_BLOB=bcm2710-rpi-3-b_4.4.50-v7+.dtb
SDIO_DTBO=wfx-sdio.dtbo
SPI_DTBO=wfx-spi.dtbo

CONFIG_FILE=config.txt
BLACKLIST_FILE=/etc/modprobe.d/raspi-blacklist.conf

SILABS_GITHUB_SCRIPTS=https://github.com/MarcDorval
SILABS_REPO_SCRIPTS=wofo

SILABS_GITHUB_FW=https://github.com/SiliconLabs
SILABS_REPO_FW=wfx_firmware

SILABS_GITHUB_DRV=https://github.com/SiliconLabs
SILABS_REPO_DRV=wfx_linux_driver_code

echo "Silicon Labs update $UPDATE_TAG script for WFx200 WiFi parts"
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
if [ -e "$SILABS_ROOT/$SILABS_REPO_SCRIPTS" ]; then
	sudo rm -rf $SILABS_ROOT/$SILABS_REPO_SCRIPTS
fi

echo "Cloning repository $SILABS_GITHUB_SCRIPTS/$SILABS_REPO_SCRIPTS.git in $(pwd)"
sudo git clone $SILABS_GITHUB_SCRIPTS/$SILABS_REPO_SCRIPTS.git --depth 5

cd "$SILABS_ROOT/$SILABS_REPO_SCRIPTS"
echo "Fetching repository $SILABS_GITHUB_SCRIPTS/$SILABS_REPO_SCRIPTS.git tag $SCRIPTS_TAG in $(pwd)"
sudo git checkout "$SCRIPTS_TAG"

if [ -e "$SILABS_ROOT/$SILABS_REPO_SCRIPTS/pi" ]; then
	echo "Copying Silicon Labs scripts in $USER_ROOT"
	cp --force $SILABS_ROOT/$SILABS_REPO_SCRIPTS/pi/* $USER_ROOT
fi
sudo chown pi: $USER_ROOT/*.sh
chmod a+x $USER_ROOT/*.sh

cd $START_DIR
# Checking kernel image, dtb and config files presence. Adding them is not present
if [ ! -e "/boot/overlays/$SDIO_DTBO" ]; then
	echo "No /boot/overlays/$SDIO_DTBO file. Copying it"
	cp --force "$SILABS_ROOT/$SILABS_REPO_SCRIPTS/boot/overlays/$SDIO_DTBO" "/boot/overlays/$SDIO_DTBO"
fi

# Displaying user information
. /home/pi/SDIO_auto.sh
echo "PI configured for SDIO auto"
echo "Use the following scripts to configure WiFi for your use case"
ls $USER_ROOT/*.sh | grep -E "_auto|_modprobe"
echo " Then enter 'sudo halt',"
echo "   wait for the activity leds to stop blinking,"
echo "   set the Devkit switch to SDIO or SPI according to your configuration"
echo "   and power-cycle the Pi to get started with your Wfx200"

echo " Once rebooted, use the /home/pi/wfx_all_checks.sh script to check your setup and how the startup is going"
echo "   NB: there is a 'check' alias for /home/pi/wfx_all_checks.sh"
