# SportPaper

A performance-tuned Minecraft 1.8 server, forked from Spigot and Paper.

Requirements
------------

To build SportPaper, the following will need to be installed and available from your shell:

* [Java 8](https://adoptium.net/temurin/releases/?version=8)
* [Git](https://git-scm.com)
* [Maven](https://maven.apache.org)

How To
------

Building, patching, and compiling are all done throught the main `sportpaper` script.

SportPaper can be built by running `./sportpaper build`  and you will find the final server jar in `SportPaper-Server/target`

Maven
-----------
Repository:
```xml
<repository>
  <id>sportpaper</id>
  <url>https://maven.pkg.github.com/Electroid/SportPaper</url>
</repository>
```
API:
```xml
<dependency>
  <groupId>app.ashcon</groupId>
  <artifactId>sportpaper-api</artifactId>
  <version>1.8.8-R0.1-SNAPSHOT</version>
  <scope>provided</scope>
</dependency>
```
Server:
```xml
<dependency>
  <groupId>app.ashcon</groupId>
  <artifactId>sportpaper</artifactId>
  <version>1.8.8-R0.1-SNAPSHOT</version>
  <scope>provided</scope>
</dependency>
```

Other Notes
-----------

SportPaper uses a shared config for most config settings.
 
 `sportpaper.yml` contains all the settings that were previously in `bukkit.yml`, `spigot.yml`, and `paper.yml`

Contributing
------------

* Before contributing to SportPaper, make sure you have run `./sportpaper build` and that you have the latest version of git installed
* To add patches to SportPaper simply make your changes in `SportPaper-API` and `SportPaper-Server` and commit them. Then run `./sportpaper rebuild`.
* To modify nms files not currently imported into SportPaper, you must add an import for that file in `scripts/importmcdev.sh` and then run `./sportpaper build` for those files to show up in `SportPaper-Server`
