#!/bin/bash

LOG_FILE="/tmp/emulationstation.log"

# Log the launch
{
    echo "=== EmulationStation Launch Log ==="
    echo "Date: $(date)"
} > "${LOG_FILE}" 2>&1

# Run emulationstation with proper environment setup
{
    echo "Launching EmulationStation..."

    # Get the current user ID
    ES_USER_ID=$(id -u)

    # Point to the standard user runtime directory (Vital for Audio/Wayland)
    export XDG_RUNTIME_DIR="/run/user/${ES_USER_ID}"

    # Point to the DBus session (Vital for PipeWire/PulseAudio discovery)
    export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

    # Set display for X11
    export DISPLAY=:0

    # Launch EmulationStation
    emulationstation
    
    echo "Exit code: $?"
} >> "${LOG_FILE}" 2>&1