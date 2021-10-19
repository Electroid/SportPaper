#!/usr/bin/env bash

cd ./Paperclip
git fetch origin master
git reset --hard 2d4c7b3
cd ..
cp ../../SportPaper-Server/target/sportpaper*-SNAPSHOT.jar ./Paperclip/sportpaper-1.8.8.jar
cp ./work/1.8.8/1.8.8.jar ./Paperclip/minecraft_server.1.8.8.jar
cd ./Paperclip
mvn -Dmcver=1.8.8 -Dvanillajar=../minecraft_server.1.8.8.jar -Dpaperjar=../sportpaper-1.8.8.jar clean package
cd ..
cp ./Paperclip/assembly/target/paperclip-1.8.8.jar ./sportpaper-paperclip.jar

echo ""
echo ""
echo ""
echo "Build success!"
echo "Copied final jar to $(pwd)/sportpaper-paperclip.jar"
