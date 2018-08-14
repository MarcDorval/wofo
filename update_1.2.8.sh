#!/bin/sh

REPO=https://github.com/MarcDorval/wofo.git

# Run with:
#  curl https://raw.githubusercontent.com/MarcDorval/wofo/master/pi/update_1.2.8.sh | sudo sh

echo "Silicon Labs update script for WFx200 WiFi parts"

! grep -q 'NAME="Raspbian GNU/Linux"' /etc/os-release && echo "You must run this script from a Raspberry" && exit 1
[ -z "$SUDO_USER" ] && echo "This script must be run with sudo" && exit 1
