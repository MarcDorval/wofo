#!/bin/bash

# Disabling SDIO overlay
sudo sed -i~ 's/^dtoverlay=sdio/#dtoverlay=sdio/m' /boot/config.txt
