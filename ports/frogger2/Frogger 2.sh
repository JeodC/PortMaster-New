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
export PORT_32BIT="Y"
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

GAMEDIR="/$directory/ports/frogger2"

export LD_LIBRARY_PATH="/usr/lib32:$GAMEDIR/libs.${DEVICE_ARCH}:$GAMEDIR/libs:$controlfolder/libs/armhf:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check if .exe exists
if [ -f "./gamedata/Frogger 2 (GMS).exe" ]; then
    # Extract its contents in place using 7zzs
    ./libs/7zzs x "./gamedata/Frogger 2 (GMS).exe" -o"./gamedata/"
fi

# Array of files to remove 
files_to_remove=("./gamedata/Frogger2FinalgmkPC.exe"
"./gamedata/Frogger 2 (GMS).exe"
"./gamedata/D3DX9_43.dll"
"./gamedata/options.ini"
"./gamedata/gmsched.dll")

# Loop through each file and remove it 
for file in "${files_to_remove[@]}"; do rm -f "$file" 
done 

# Check if "data.win" exists and its MD5 checksum matches the specified value then apply patch
if [ -f "gamedata/data.win" ]; then
    checksum=$(md5sum "gamedata/data.win" | awk '{print $1}')
    if [ "$checksum" = "2c5167c1a7e603e36e937e2218580802" ]; then
        $ESUDO $controlfolder/xdelta3 -d -s "gamedata/data.win" -f "./patch/patch.xdelta3" "gamedata/game.droid" && \
        rm "gamedata/data.win"
    fi
fi
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid

$GPTOKEYB "gmloader" -c "./frogger2.gptk" &
echo "Loading, please wait... " > /dev/tty0

$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader frogger2.apk

pm_finish
