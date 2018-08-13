#!/bin/bash

# Un-Blacklisting SDIO driver
sudo sed -i~ 's/^blacklist wfx_wlan_sdio/#blacklist wfx_wlan_sdio/m' /etc/modprobe.d/raspi-blacklist.conf
