#!/bin/bash

sudo apt install git lsb-release pulseaudio

RETROPIE_SETUP="${HOME}/RetroPie-Setup"
if [ ! -d "${RETROPIE_SETUP}" ]; then
    git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git "${RETROPIE_SETUP}"
    chmod +x "${HOME}/RetroPie-Setup/retropie_setup.sh"
    sudo "${HOME}/RetroPie-Setup/retropie_setup.sh"
fi

cp "./retropie/Xbox\ Series\ X\ Controller.cfg" /opt/retropie/configs/all/retroarch-joypads