#!/bin/bash

###############################################################################
# Autostart
###############################################################################

# # Wayland/labwc
# mkdir -p ~/.config/labwc

# cat << 'EOF' > ~/.config/labwc/autostart
# emulationstation
# EOF

# chmod +x ~/.config/labwc/autostart

# Autostart - X11
AUTOSTART="${HOME}/.config/autostart"
mkdir -p "${AUTOSTART}"
cp ./emulationstation/emulationstation.desktop "${AUTOSTART}/emulationstation.desktop"

ES_AUTOSTART="${HOME}/emulationstation"
mkdir -p "${ES_AUTOSTART}"
cp ./emulationstation/autostart.sh "${ES_AUTOSTART}/autostart.sh"
chmod +x "${ES_AUTOSTART}/autostart.sh"

###############################################################################
# Setup custom scripts
###############################################################################
mkdir -p "${HOME}/emulationstation/custom"

# moonlight
cp ./emulationstation/eglfs_kms.json "${HOME}/eglfs_kms.json"

MOONLIGHT_SCRIPT="${HOME}/emulationstation/custom/moonlight.sh"
cp ./emulationstation/moonlight.sh "${MOONLIGHT_SCRIPT}"
chmod +x "${MOONLIGHT_SCRIPT}"

# desktop
DESKTOP_SCRIPT="${HOME}/emulationstation/custom/desktop.sh"
cp ./emulationstation/desktop.sh "${DESKTOP_SCRIPT}"
chmod +x "${DESKTOP_SCRIPT}"

# shutdown
SHUTDOWN_SCRIPT="${HOME}/emulationstation/custom/shutdown.sh"
cp ./emulationstation/shutdown.sh "${SHUTDOWN_SCRIPT}"
chmod +x "${SHUTDOWN_SCRIPT}"

# reboot
REBOOT_SCRIPT="${HOME}/emulationstation/custom/reboot.sh"
cp ./emulationstation/reboot.sh "${REBOOT_SCRIPT}"
chmod +x "${REBOOT_SCRIPT}"

###############################################################################
# allow power control without password
###############################################################################
sudo tee /etc/sudoers.d/emulationstation-power > /dev/null << 'EOF'
pi ALL=(ALL) NOPASSWD: /sbin/poweroff, /sbin/reboot, /usr/bin/openvt, /usr/bin/chvt
EOF

sudo chmod 0440 /etc/sudoers.d/emulationstation-power

###############################################################################
# emulationstation config
###############################################################################
ES_CONFIG="${HOME}/.emulationstation"
mkdir -p "${ES_CONFIG}"
cp /etc/emulationstation/es_systems.cfg "${ES_CONFIG}/es_systems.cfg"

if ! grep -q '<name>custom</name>' "${HOME}/.emulationstation/es_systems.cfg"; then
  sed -i '/<\/systemList>/i\
  <system>\
    <name>custom</name>\
    <fullname>Custom</fullname>\
    <path>/home/mchoc/emulationstation/custom</path>\
    <extension>.sh</extension>\
    <command>%ROM%</command>\
    <theme>custom-collections</theme>\
  </system>' ~/.emulationstation/es_systems.cfg
fi