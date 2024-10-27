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

GAMEDIR="/$directory/ports/nightshift"

export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:/usr/lib32:$GAMEDIR/libs:$controlfolder/libs/armhf:$LD_LIBRARY_PATH"
export GMLOADER_DEPTH_DISABLE=1
export GMLOADER_SAVEDIR="$GAMEDIR/gamedata/"
export GMLOADER_PLATFORM="os_linux"

cd "$GAMEDIR"
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

# Check if .exe exists
if [ -f "./gamedata/NightShift.exe" ]; then
    # Extract its contents in place using 7zzs
    ./libs/7zzs x "./gamedata/NightShift.exe" -o"./gamedata/"
fi

# Remove unnecessary files after extraction
rm -f ./gamedata/NightShift.exe
rm -f ./gamedata/D3DX9_43.dll
rm -f ./gamedata/options.ini

# Check if there are .ogg files in ./gamedata
if [ -n "$(ls ./gamedata/*.ogg 2>/dev/null)" ]; then
    # Move all .ogg files from ./gamedata to ./assets
    mkdir -p ./assets
    mv ./gamedata/*.ogg ./assets/ || exit 1

    # Zip the contents of ./nightshift.apk including the .ogg files
    zip -r -0 ./nightshift.apk ./assets/ || exit 1
    rm -Rf "$GAMEDIR/assets/" || exit 1
fi

# Rename data.win to game.droid if it exists
[ -f "./gamedata/data.win" ] && mv gamedata/data.win gamedata/game.droid

$GPTOKEYB "gmloader" -c "./nightshift.gptk" &
echo "Loading, please wait... " > /dev/tty0

$ESUDO chmod +x "$GAMEDIR/gmloader"
pm_platform_helper "$GAMEDIR/gmloader"
./gmloader nightshift.apk

pm_finish
