#!/bin/bash

# Disabling SPI overlay
sudo sed -i~ 's/^\s*dtoverlay=wfx-spi/#dtoverlay=wfx-spi/m' /boot/config.txt
