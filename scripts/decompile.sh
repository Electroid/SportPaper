#!/usr/bin/env bash

(
set -e
PS1="$"
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/base"
minecraftversion=$(grep minecraftVersion "$workdir/Paper/BuildData/info.json" | cut -d '"' -f 4)
decompiledir="$workdir/Minecraft/$minecraftversion"
classdir="$decompiledir/classes"

echo "Extracting NMS classes..."
if [ ! -d "$classdir" ]; then
    mkdir -p "$classdir"
    cd "$classdir"
    set +e
    if ! jar xf "$decompiledir/$minecraftversion-mapped.jar" net/minecraft/server; then
        cd "$basedir"
        echo "Failed to extract NMS classes."
        exit 1
    fi
    set -e
fi

if [ ! -d "$decompiledir/net/minecraft/server" ]; then
    echo "Decompiling classes..."
    cd "$basedir"
    set +e
    if ! java -jar "$workdir/Paper/BuildData/bin/fernflower.jar" -dgs=1 -hdc=0 -rbr=0 -asc=1 -udv=0 "$classdir" "$decompiledir"; then
        rm -rf "$decompiledir/net/minecraft/server"
        echo "Failed to decompile classes."
        exit 1
    fi
    set -e
fi
)
