# SportPaper

A fork of Paper 1.8 with changes for the Stratus Network using Magnet's build system.

Requirements
------------

To build SportBukkit, the following will need to be installed and available from your shell:

* [JDK 8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
* [Git](https://git-scm.com)
* [Maven](https://maven.apache.org)

How To
------

Building, patching, and compiling are all done throught the main `sportpaper` script.

SportPaper can be built by running `./sportpaper build`  and you will find the final server jar in `SportPaper-Server/target`

Other Notes
-----------

SportPaper uses a shared config for most config settings.
 
 `sportpaper.yml` contains all the settings that were previously in `bukkit.yml`, `spigot.yml`, and `paper.yml`

Contributing
------------

* Before contributing to SportPaper, make sure you have run `./sportpaper build` and that you have the latest version of git installed
* To add patches to SportPaper simply make your changes in `SportPaper-API` and `SportPaper-Server` and commit them. Then run `./sportpaper rebuild`.
* To modify nms files not currently imported into SportPaper, you must add an import for that file in `scripts/importmcdev.sh` and then run `./sportpaper build` for those files to show up in `SportPaper-Server`
