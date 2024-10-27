#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
source $controlfolder/device_info.txt
export PORT_32BIT="Y"

get_controls
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

$ESUDO chmod 666 /dev/tty0

GAMEDIR=/$directory/ports/arengius

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs.${DEVICE_ARCH}:$GAMEDIR/libs:$controlfolder/libs/armhf:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"

cd $GAMEDIR

# Rename data.win file
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "gmloader" -c "arengius.gptk" &

$ESUDO chmod +x "$GAMEDIR/gmloader" 

./gmloader game.apk

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty0
