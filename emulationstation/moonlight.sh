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
  MOONLIGHT_USER_ID=$(id -u)
  export XDG_RUNTIME_DIR="/run/user/${MOONLIGHT_USER_ID}"

  # 3. Point to the DBus session (Vital for PipeWire/PulseAudio discovery)
  export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

  # 4. Launch Moonlight
  QT_QPA_PLATFORM=eglfs QT_QPA_EGLFS_KMS_CONFIG="${HOME}/eglfs_kms.json" moonlight-qt

  sudo chvt 7

  echo "Exit code: $?"
} >> "${LOG_FILE}" 2>&1

# Restart the Wayland compositor and EmulationStation
emulationstation >> "${LOG_FILE}" 2>&1