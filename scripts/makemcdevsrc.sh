#!/usr/bin/env bash

(
set -e
PS1="$"

basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/base"
minecraftversion=$(grep minecraftVersion "$workdir/Paper/BuildData/info.json" | cut -d '"' -f 4)
decompiledir="$workdir/Minecraft/$minecraftversion"
nms="$decompiledir/net/minecraft/server"
papernms="$basedir/SportPaper-Server/src/main/java/net/minecraft/server"
mcdevsrc="${decompiledir}/src/net/minecraft/server"
rm -rf "${mcdevsrc}"
mkdir -p "${mcdevsrc}"
cd "${nms}"

while IFS= read -r -d '' file
do
    if [ ! -f "${papernms}/${file}" ]; then
		destdir="${mcdevsrc}"/$(dirname "${file}")
		mkdir -p "${destdir}"
		cp "${file}" "${destdir}"
    fi
done < <(find . -name '*.java' -print0)

cd "$basedir"
echo "Built $decompiledir/src to be included in your project for src access";
)
