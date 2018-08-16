#!/bin/bash

# Enabling SDIO overlay
SDIO_IN_MODULES=$(cat /etc/modules | grep ^wfx_wlan_sdio)
if [ -z "$SDIO_IN_MODULES" ]; then
	echo "wfx_wlan_sdio" | sudo tee /etc/modules > /dev/null
fi
