# One easy way to get access to the following aliases upon startup:
#   Add the following line to /home/pi/.profile:
#   . ./silabs_aliases.sh
#   This line will source the aliases.

alias black='             sudo nano /etc/modprobe.d/raspi-blacklist.conf'
alias blacklist='         cat /etc/modprobe.d/raspi-blacklist.conf | grep -v ^# | grep -v ^$'
alias mmc-bus='           tree /sys/bus/mmc'
alias check='             /home/pi/wfx_all_checks.sh'
alias cleanup='           echo "" > .bash_history ; sudo rm /var/log/syslog ; history -c ; '
alias cmdline='           cat /boot/cmdline.txt | grep -v ^# | grep -v ^$ '
alias conf='              sudo nano /boot/config.txt '
alias config='            cat /boot/config.txt  | grep -v ^# | grep -v ^$ '
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias follow='            dmesg -w '
alias grep='grep --color=auto'
alias kernel='            uname -r '
alias ls='ls --color=auto'
alias machine='           uname -m '
alias mmc1='              dmesg | grep mmc1'
alias mmc-drivers='       tree /sys/bus/platform/drivers/mmc-bcm2835'
alias model='             cat /sys/firmware/devicetree/base/model '
alias modules='           cat /etc/modules     | grep -v ^# | grep -v ^$ '
alias options='           cat /etc/modprobe.d/wfx_core.conf | grep -v ^# | grep -v ^$ ; cat /etc/modprobe.d/wfx_wlan_sdio.conf | grep -v ^# | grep -v ^$ ;  cat /etc/modprobe.d/wfx_wlan_spi.conf | grep -v ^# | grep -v ^$ ;'
alias reb='               sudo reboot '
alias scan='              wpa_cli scan ; sleep 3; wpa_cli scan_results '
alias sdio-load='         sudo modprobe -v wfx_wlan_sdio'
alias sdio-reload='       sudo modprobe -v wfx_wlan_sdio -r ; echo 3f300000.mmc | sudo tee /sys/bus/platform/drivers/mmc-bcm2835/unbind ; echo 3f300000.mmc | sudo tee /sys/bus/platform/drivers/mmc-bcm2835/bind ; sudo modprobe -v wfx_wlan_sdio'
alias sdio-remove='       sudo modprobe -v wfx_wlan_sdio -r'
alias spi-bus='           tree /sys/bus/spi'
alias spi-load='          sudo modprobe -v wfx_wlan_spi'
alias spi-max-frequency=' fdtdump /boot/overlays/wfx-spi.dtbo | grep max '
alias spi-overclock='     cat /boot/config.txt | grep spi_overclock '
alias spi-reload='        sudo modprobe -v wfx_wlan_spi -r ; sudo modprobe -v wfx_wlan_spi'
alias spi-remove='        sudo modprobe -v wfx_wlan_spi -r'
alias wfx-detected='      dmesg | grep -i "wf"  | grep    "detected" '
alias wfx-drivers='       ls -al /lib/modules/$(kernel)/kernel/drivers/net/wireless/siliconlabs/wfx/wfx_* '
alias wfx-firmware='      ls -al /lib/firmware/wfm_* '
alias wfx-fw='            dmesg | grep -i "wf"  | grep -E "firmware|Label" '
alias wfx-infos='         modinfo wfx_core ; modinfo wfx_wlan_sdio ; modinfo wfx_wlan_spi '
alias wfx-init='          dmesg | grep -i "wf"  | grep    "done" '
alias wfx-lsmod='         lsmod | grep -i " wfx" '
alias wfx-msg='           dmesg | grep -i "wf"  '
alias wfx-overlay='       config | grep overlay | grep -E "sdio|spi" '
alias wfx-pds='           ls -al /lib/firmware/pds_* '
alias wfx-probe='         dmesg | grep -i "wf"  | grep -i "Probe" '
alias wfx-version='       modinfo wfx_core  | grep -E "^filename|^version"; modinfo wfx_wlan_sdio  | grep -E "^filename|^version"; modinfo wfx_wlan_spi  | grep -E "^filename|^version"'
