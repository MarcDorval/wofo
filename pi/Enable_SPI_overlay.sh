#!/bin/bash

# Enabling SPI overlay
sudo sed -i~ 's/^#dtoverlay=wfx-spi/dtoverlay=wfx-spi/m' /boot/config.txt
