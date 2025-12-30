#!/bin/bash

cd "$(dirname "$0")"

sudo apt update
sudo apt upgrade -y

./retropie.sh
./moonlight.sh
./emulationstation.sh