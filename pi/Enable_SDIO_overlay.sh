#!/bin/bash

# Enabling SDIO overlay
sudo sed -i~ 's/^#dtoverlay=sdio/dtoverlay=sdio/m' /boot/config.txt
