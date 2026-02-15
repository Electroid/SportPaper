#!/usr/bin/env bash

(
set -e
PS1="$"
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/base"
minecraftversion="$(grep minecraftVersion "${workdir}/Paper/BuildData/info.json" | cut -d '"' -f 4)"
minecraftserverurl="https://launcher.mojang.com/v1/objects/5fafba3f58c40dc51b5c3ca72a98f62dfdae1db7/server.jar"
minecrafthash=$(grep minecraftHash "${workdir}/Paper/BuildData/info.json" | cut -d '"' -f 4)
accesstransforms="$workdir/Paper/BuildData/mappings/"$(grep accessTransforms "${workdir}/Paper/BuildData/info.json" | cut -d '"' -f 4)
classmappings="$workdir/Paper/BuildData/mappings/"$(grep classMappings "${workdir}/Paper/BuildData/info.json" | cut -d '"' -f 4)
membermappings="$workdir/Paper/BuildData/mappings/"$(grep memberMappings "${workdir}/Paper/BuildData/info.json" | cut -d '"' -f 4)
packagemappings="$workdir/Paper/BuildData/mappings/"$(grep packageMappings "${workdir}/Paper/BuildData/info.json" | cut -d '"' -f 4)
decompiledir="$workdir/Minecraft/$minecraftversion"
jarpath="$decompiledir/$minecraftversion"
mkdir -p "$decompiledir"

echo "Downloading unmapped vanilla jar..."
if [ ! -f  "$jarpath.jar" ]; then
    if ! curl -s -o "$jarpath.jar" "$minecraftserverurl"; then
        echo "Failed to download the vanilla server jar. Check connectivity or try again later."
        exit 1
    fi
fi

# OS X & FreeBSD don't have md5sum, just md5 -r
command -v md5sum >/dev/null 2>&1 || {
    command -v md5 >/dev/null 2>&1 && {
        md5sum() { md5 -r "$@"; }
        echo "md5sum command not found, falling back to md5 instead"
    } || {
        echo >&2 "No md5sum or md5 command found"
        exit 1
    }
}

checksum=$(md5sum "$jarpath.jar" | cut -d ' ' -f 1)
if [ "$checksum" != "$minecrafthash" ]; then
    echo "The MD5 checksum of the downloaded server jar does not match the BuildData hash."
    exit 1
fi

# These specialsource commands are from https://hub.spigotmc.org/stash/projects/SPIGOT/repos/builddata/browse/info.json
# We use upstream Spigot SpecialSource-2 for applying mappings for modern Java support
echo "Applying class mappings..."
if [ ! -f "$jarpath-cl.jar" ]; then
    if ! java -jar "$workdir/BuildData/bin/SpecialSource-2.jar" map -i "$jarpath.jar" -m "$classmappings" -o "$jarpath-cl.jar" 1>/dev/null; then
        echo "Failed to apply class mappings."
        exit 1
    fi
fi

echo "Applying member mappings..."
if [ ! -f "$jarpath-m.jar" ]; then
    if ! java -jar "$workdir/BuildData/bin/SpecialSource-2.jar" map -i "$jarpath-cl.jar" -m "$membermappings" -o "$jarpath-m.jar" 1>/dev/null; then
        echo "Failed to apply member mappings."
        exit 1
    fi
fi

echo "Creating remapped jar..."
if [ ! -f "$jarpath-mapped.jar" ]; then
    if ! java -jar "$workdir/Paper/BuildData/bin/SpecialSource.jar" --kill-lvt -i "$jarpath-m.jar" --access-transformer "$accesstransforms" -m "$packagemappings" -o "$jarpath-mapped.jar" 1>/dev/null; then
        echo "Failed to create remapped jar."
        exit 1
    fi
fi

echo "Installing remapped jar..."
cd "$workdir/Paper/CraftBukkit" # Need to be in a directory with a valid POM at the time of install.
if ! mvn install:install-file -q -Dfile="$jarpath-mapped.jar" -Dpackaging=jar -DgroupId=org.spigotmc -DartifactId=minecraft-server -Dversion="$minecraftversion-SNAPSHOT"; then
    echo "Failed to install remapped jar."
    exit 1
fi
)
