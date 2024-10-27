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
get_controls

## TODO: Change to PortMaster/tty when Johnnyonflame merges the changes in,
CUR_TTY=/dev/tty0

PORTDIR="/$directory/ports"
GAMEDIR="$PORTDIR/kobodeluxe"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
cd $GAMEDIR

$ESUDO chmod 666 $CUR_TTY
export TERM=linux
printf "\033c" > $CUR_TTY
## RUN SCRIPT HERE

export PORTMASTER_HOME="$GAMEDIR"
export LD_LIBRARY_PATH="$GAMEDIR/libs:$GAMEDIR/libs.${DEVICE_ARCH}:$controlfolder/libs/aarch64:$LD_LIBRARY_PATH"

echo "Starting game." > $CUR_TTY

$GPTOKEYB "kobodl" -c kobodl.gptk &
./kobodl

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events &

# Disable console
printf "\033c" > $CUR_TTY
