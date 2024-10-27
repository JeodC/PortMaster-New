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

get_controls

GAMEDIR=/$directory/ports/supertux
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

cd $GAMEDIR

export LD_LIBRARY_PATH="$GAMEDIR/libs:$GAMEDIR/libs.${DEVICE_ARCH}:$controlfolder/libs/aarch64:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SUPERTUX2_DATA_DIR=$GAMEDIR
export SUPERTUX2_USER_DIR=$GAMEDIR

$ESUDO chmod 666 /dev/uinput

$GPTOKEYB "supertux2" -c "./supertux.gptk" &
./supertux2 -a $DISPLAY_WIDTH:$DISPLAY_HEIGHT -g $DISPLAY_WIDTH"x"$DISPLAY_HEIGHT

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
