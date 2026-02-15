#!/usr/bin/env bash

(
set -e
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/base"
mcver=$(grep minecraftVersion "$workdir/Paper/BuildData/info.json" | cut -d '"' -f 4)
paperjar="$basedir/SportPaper-Server/target/sportpaper-$mcver-R0.1-SNAPSHOT.jar"
vanillajar="$workdir/Minecraft/$mcver/$mcver.jar"

(
    cd "$workdir/Paper/Paperclip"

    # Make sure we use https and not http for clojars repo
    perl -pi -e 's/http:\/\/clojars/https:\/\/clojars/g' ./java8/pom.xml
    # Use current Paper repo
    perl -pi -e 's/https:\/\/papermc.io\/repo\/repository\/maven-releases\//https:\/\/repo.papermc.io\/repository\/maven-public\//g' ./assembly/pom.xml
    # Ensure we're using paperclip-maven-plugin 2.0.1
    perl -pi -e 's/2.0.0/2.0.1/g'  ./assembly/pom.xml

    mvn clean package "-Dmcver=$mcver" "-Dpaperjar=$paperjar" "-Dvanillajar=$vanillajar"

    git restore ./*/pom.xml
)
cp "$workdir/Paper/Paperclip/assembly/target/paperclip-${mcver}.jar" "$basedir/sportpaper.jar"

echo ""
echo ""
echo ""
echo "Build success!"
echo "Copied final jar to $(cd "$basedir" && pwd -P)/sportpaper.jar"
) || exit 1
