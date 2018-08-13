#!/bin/bash

# Blacklisting SPI driver
sudo sed -i~ 's/^#blacklist wfx_wlan_spi/blacklist wfx_wlan_spi/m' /etc/modprobe.d/raspi-blacklist.conf
