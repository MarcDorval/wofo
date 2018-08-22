#!/bin/bash

# Now using wfx-sdio overlay instead of sdio overlay
sudo sed -i~ 's/dtoverlay=sdio/dtoverlay=wfx-sdio/m' /boot/config.txt
# Enabling SDIO overlay
sudo sed -i~ 's/^#dtoverlay=sdio/dtoverlay=sdio/m' /boot/config.txt
