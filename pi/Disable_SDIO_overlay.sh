#!/bin/bash

# Now using wfx-sdio overlay instead of sdio overlay
sudo sed -i~ 's/dtoverlay=sdio/dtoverlay=wfx-sdio/m' /boot/config.txt
# Disabling SDIO overlay
sudo sed -i~ 's/^dtoverlay=wfx-sdio/#dtoverlay=wfx-sdio/m' /boot/config.txt
