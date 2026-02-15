#!/usr/bin/env bash

(
PS1="$"
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/base"
minecraftversion=$(grep minecraftVersion "$workdir/BuildData/info.json" | cut -d '"' -f 4)
gitcmd="git -c commit.gpgsign=false"
applycmd="$gitcmd am --3way --ignore-whitespace"
# Windows detection to workaround ARG_MAX limitation
windows="$([[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]] && echo "true" || echo "false")"

echo "Rebuilding Forked projects.... "

function applyPatch {
    what=$1
    what_name=$(basename "$what")
    target=$2
    branch=$3
    patch_folder=$4

    cd "$basedir/$what"
    $gitcmd fetch
    $gitcmd branch -f upstream "$branch" >/dev/null

    cd "$basedir"
    if [ ! -d "$basedir/$target" ]; then
        $gitcmd clone "$what" "$target"
    fi
    cd "$basedir/$target"

    echo "Resetting $target to $what_name..."
    $gitcmd remote rm upstream > /dev/null 2>&1
    $gitcmd remote add upstream "$basedir/$what" >/dev/null 2>&1
    $gitcmd checkout master 2>/dev/null || $gitcmd checkout -b master
    $gitcmd fetch upstream >/dev/null 2>&1
    $gitcmd reset --hard upstream/upstream

    echo "  Applying patches to $target..."

    statusfile=".git/patch-apply-failed"
    rm -f "$statusfile"
    git config commit.gpgsign false
    $gitcmd am --abort >/dev/null 2>&1

    # Special case Windows handling because of ARG_MAX constraint
    exit_code=0
    if [[ $windows == "true" ]]; then
        echo "  Using workaround for Windows ARG_MAX constraint"
        find "$basedir/$patch_folder/"*.patch -print0 | xargs -0 "$applycmd" || exit_code=$?
    else
        $applycmd "$basedir/$patch_folder/"*.patch || exit_code=$?
    fi

    if [ $exit_code != "0" ]; then
        echo 1 > "$statusfile"
        echo "  Something did not apply cleanly to $target."
        echo "  Please review above details and finish the apply then"
        echo "  save the changes with rebuildPatches.sh"

        # On Windows, finishing the patch apply will only fix the latest patch
        # users will need to rebuild from that point and then re-run the patch
        # process to continue
        if [[ $windows == "true" ]]; then
            echo ""
            echo "  Because you're on Windows you'll need to finish the AM,"
            echo "  rebuild all patches, and then re-run the patch apply again."
            echo "  Consider using the scripts with Windows Subsystem for Linux."
        fi

        exit 1
    else
        rm -f "$statusfile"
        echo "  Patches applied cleanly to $target"
    fi
}

# Move into Paper dir
cd "$workdir/Paper"
basedir=$(pwd)
# Apply Spigot
(
    applyPatch Bukkit Spigot-API HEAD Bukkit-Patches &&
    applyPatch CraftBukkit Spigot-Server patched CraftBukkit-Patches
) || (
    echo "Failed to apply Spigot Patches"
    exit 1
) || exit 1
# Apply Paper
(
    applyPatch Spigot-API PaperSpigot-API HEAD Spigot-API-Patches &&
    applyPatch Spigot-Server PaperSpigot-Server HEAD Spigot-Server-Patches
) || (
    echo "Failed to apply Paper Patches"
    exit 1
) || exit 1
# Move out of Paper
basedir="$1"
cd "$basedir"

echo "Importing MC Dev"

./scripts/importmcdev.sh "$basedir" || exit 1

# Apply SportPaper
(
    applyPatch "base/Paper/PaperSpigot-API" SportPaper-API HEAD patches/api &&
    applyPatch "base/Paper/PaperSpigot-Server" SportPaper-Server HEAD patches/server
    cd "$basedir"

    # if we have previously ran ./sportpaper mcdev, update it
    if [ -d "$workdir/Minecraft/$minecraftversion/src" ]; then
        ./scripts/makemcdevsrc.sh "$basedir"
    fi
) || (
    echo "Failed to apply SportPaper Patches"
    exit 1
) || exit 1
) || exit 1
