#!/usr/bin/env bash

(
set -e
nms="net/minecraft/server"
export MODLOG=""
PS1="$"
basedir="$(cd "$1" && pwd -P)"
source "$basedir/scripts/functions.sh"
gitcmd="git -c commit.gpgsign=false"

workdir="$basedir/base"
minecraftversion=$(grep minecraftVersion "$workdir/Paper/BuildData/info.json" | cut -d '"' -f 4)
decompiledir="$workdir/Minecraft/$minecraftversion"

export importedmcdev=""
function import {
    export importedmcdev="$importedmcdev $1"
    file="${1}.java"
    target="$workdir/Paper/PaperSpigot-Server/src/main/java/$nms/$file"
    base="$decompiledir/$nms/$file"

    if [[ ! -f "$target" ]]; then
        export MODLOG="$MODLOG  Imported $file from mc-dev\n";
        echo "Copying $base to $target"
        cp "$base" "$target" || exit 1
    else
        echo "UN-NEEDED IMPORT: $file"
    fi
}
(
    cd "$workdir/Paper/PaperSpigot-Server/"
    lastlog=$($gitcmd log -1 --oneline)
    if [[ "$lastlog" = *"mc-dev Imports"* ]]; then
        $gitcmd reset --hard HEAD^
    fi
)

import BlockBeacon
import BlockCarpet
import BlockState
import BlockStateInteger
import ChunkCache
import ChunkCoordIntPair
import DamageSource
import EntityTypes
import IChunkLoader
import IEntitySelector
import ItemFireworks
import ItemGoldenApple
import ItemPotion
import MerchantRecipeList
import NibbleArray
import Packet
import PacketCompressor
import PacketDecompressor
import PacketDecrypter
import PacketEncrypter
import PacketPlayInUseEntity
import PacketPlayOutAttachEntity
import PacketPlayOutEntityMetadata
import PacketPlayOutNamedEntitySpawn
import PacketPlayOutPlayerInfo
import PacketPlayOutScoreboardTeam
import PacketPlayOutSpawnEntity
import PacketPlayOutSpawnEntityLiving
import PacketPrepender
import PacketSplitter
import PersistentScoreboard
import RemoteControlListener
import ServerNBTManager
import ServerPing
import SlotResult
import StatisticList
import WorldGenCaves
import WorldSettings

set -e
cd "$workdir/Paper/PaperSpigot-Server/"
rm -rf nms-patches applyPatches.sh makePatches.sh >/dev/null 2>&1
$gitcmd add --force . -A >/dev/null 2>&1
echo -e "mc-dev Imports\n\n$MODLOG" | $gitcmd commit . -F -
)
