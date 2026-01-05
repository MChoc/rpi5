#!/bin/bash

cd "$(dirname "$0")" || exit 1

sudo apt update
sudo apt upgrade -y

./bluetooth.sh "Xbox Wireless Controller"
./retropie/retropie.sh
./moonlight.sh
./emulationstation/emulationstation.sh