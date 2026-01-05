#!/bin/bash

# Bluetooth device connection script
# Usage: ./bluetooth.sh <DEVICE_NAME>
# Example: ./bluetooth.sh "My Bluetooth Speaker"

DEVICE_NAME="$1"
TIMEOUT=60

if [ -z "${DEVICE_NAME}" ]; then
    echo "Error: Device name required"
    echo "Usage $0 <MAC_ADDRESS>"
    exit 1
fi

echo "Targeting device: ${DEVICE_NAME}..."

# Function to find MAC address by device name
find_device_mac() {
    local name="$1"

    # Search in paired/known devices and scan results
    bluetoothctl devices | grep -i "${name}" | head -1 | awk '{print $2}'
}

# Try to find device in already known devices
MAC_ADDRESS=$(find_device_mac "${DEVICE_NAME}")

if [ -n "${MAC_ADDRESS}" ]; then
    echo "Found device ${DEVICE_NAME} with address: ${MAC_ADDRESS}"

    # Check if device is already paired and connected
    if bluetoothctl info "${MAC_ADDRESS}" 2>/dev/null | grep -q "Connected: yes"; then
        echo "Device ${DEVICE_NAME} is already connected."
        exit 0
    fi

    # Check if device is already paired (but not connected)
    if bluetoothctl info "${DEVICE_NAME}" 2>/dev/null | grep -q "Paired: yes"; then
        echo "Device ${DEVICE_NAME} is already paired. Attempting to connect..."
        if bluetoothctl connect "${DEVICE_NAME}"; then
            echo "Successfully connected to ${DEVICE_NAME}"
            exit 0
        else
            echo "Failed to connect to already-paired device. Will attempt re-pairing..."
        fi
    fi
else
    echo "Device ${DEVICE_NAME} not found in known devices. Will scan..."
fi


# Power on Bluetooth
echo "Powering on Bluetooth..."
bluetoothctl power on

# Start scanning in background
echo "Starting device scan (timeout: ${TIMEOUT}s)..."
bluetoothctl --timeout "${TIMEOUT}" scan on &
SCAN_PID=$!

# Wait for device to be discovered
echo "Waiting for device ${DEVICE_NAME} to be discovered..."
ELAPSED=0
DISCOVERED=false


while [ $ELAPSED -lt $TIMEOUT ]; do
    # Look for device by name in scan results
    MAC_ADDRESS=$(find_device_mac "${DEVICE_NAME}")

    if [ -n "${MAC_ADDRESS}" ]; then
        DISCOVERED=true
        echo "Device ${DEVICE_NAME} discovered with address: ${MAC_ADDRESS}"
        break
    fi
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done

# Stop scanning
kill $SCAN_PID 2>/dev/null
bluetoothctl scan off

if [ "${DISCOVERED}" = false ]; then
    echo "Error: Device ${DEVICE_NAME} not found after ${TIMEOUT}s"
    echo "Available devices:"
    bluetoothctl devices
    exit 1
fi

# Pair with device
echo "Pairing with ${DEVICE_NAME} (${MAC_ADDRESS})..."
if ! bluetoothctl pair "${MAC_ADDRESS}"; then
    echo "Warning: Pairing failed or device already paired"
fi

# Trust device
echo "Trusting ${DEVICE_NAME}..."
if ! bluetoothctl trust "${MAC_ADDRESS}"; then
    echo "Warning: Failed to trust device"
fi

# Connect to device
echo "Connecting to ${DEVICE_NAME}..."
if bluetoothctl connect "${MAC_ADDRESS}"; then
    echo "Successfully connected to ${DEVICE_NAME}"

    # Display device info
    echo ""
    echo "Device information:"
    bluetoothctl info "${MAC_ADDRESS}"
    exit 0
else
    echo "Error: Failed to connect to ${DEVICE_NAME}"
    exit 1
fi