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
mkdir -p ~/.config/autostart

cat << 'EOF' > ~/.config/autostart/emulationstation.desktop
[Desktop Entry]
Type=Application
Name=EmulationStation
Exec=emulationstation
X-GNOME-Autostart-enabled=true
EOF

###############################################################################
# Setup custom scripts
###############################################################################
mkdir -p ~/emulationstation/custom

# moonlight
cat << 'EOF' > ~/eglfs_kms.json
{
  "device": "/dev/dri/card1",
  "outputs": [
    {
      "name": "HDMI1",
      "mode": "preferred"
    }
  ]
}
EOF

cat << 'EOF' > ~/emulationstation/custom/moonlight.sh
#!/bin/bash

LOG_FILE="/tmp/moonlight-qt.log"

# Log the launch
{
  echo "=== Moonlight-Qt Launch Log ==="
  echo "Date: $(date)"
} > "${LOG_FILE}" 2>&1

# Run moonlight-qt directly on the framebuffer (Qt EGLFS)
{
  echo "Launching moonlight-qt..."

  sudo chvt 3

  # 1. Point to the physical terminal (so Qt knows where to paint)
  export QT_QPA_EGLFS_TTY=/dev/tty2

  # 2. Point to the standard user runtime directory (Vital for Audio/Wayland)
  export XDG_RUNTIME_DIR=/run/user/$(id -u)

  # 3. Point to the DBus session (Vital for PipeWire/PulseAudio discovery)
  export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

  # 4. Launch Moonlight
  QT_QPA_PLATFORM=eglfs QT_QPA_EGLFS_KMS_CONFIG=~/eglfs_kms.json moonlight-qt

  sudo chvt 7

  echo "Exit code: $?"
} >> "${LOG_FILE}" 2>&1

# Restart the Wayland compositor and EmulationStation
emulationstation >> "${LOG_FILE}" 2>&1
EOF

chmod +x ~/emulationstation/custom/moonlight.sh

# desktop
cat << 'EOF' > ~/emulationstation/custom/desktop.sh
#!/bin/bash
killall emulationstation 2>/dev/null
EOF

chmod +x ~/emulationstation/custom/desktop.sh

# shutdown
cat << 'EOF' > ~/emulationstation/custom/shutdown.sh
#!/bin/bash
sudo poweroff
EOF

chmod +x ~/emulationstation/custom/shutdown.sh

# reboot
cat << 'EOF' > ~/emulationstation/custom/reboot.sh
#!/bin/bash
sudo reboot
EOF

chmod +x ~/emulationstation/custom/reboot.sh

###############################################################################
# allow power control without password
###############################################################################
sudo tee /etc/sudoers.d/emulationstation-power > /dev/null << 'EOF'
pi ALL=(ALL) NOPASSWD: /sbin/poweroff, /sbin/reboot, /usr/bin/openvt
EOF

sudo chmod 0440 /etc/sudoers.d/emulationstation-power

###############################################################################
# emulationstation config
###############################################################################
mkdir -p ~/.emulationstation

cp /etc/emulationstation/es_systems.cfg ~/.emulationstation/es_systems.cfg

sed -i '/<\/systemList>/i\
  <system>\
    <name>custom</name>\
    <fullname>Custom</fullname>\
    <path>/home/mchoc/emulationstation/custom</path>\
    <extension>.sh</extension>\
    <command>%ROM%</command>\
    <theme>custom-collections</theme>\
  </system>' ~/.emulationstation/es_systems.cfg
