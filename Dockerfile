FROM maven:3-jdk-8-alpine

# Install proper packages and setup git
RUN apk add patch --update && \
	apk add --no-cache git && \
  	git config --global user.email "ashcon@partovi.net" && \
  	git config --global user.name "Ashcon Partovi"

# Copy over project files into workspace
WORKDIR build
COPY . .
RUN chmod a+x scripts/*

# Generate the patches
RUN ./sportpaper rebuild

# Build the JAR
RUN ./sportpaper build

FROM openjdk:8-jre-alpine

# Copy over assets from build to the server workspace
WORKDIR server
COPY --from=0 build/SportPaper-Server/target/sportpaper*.jar sportpaper.jar
COPY sportpaper.yml .

# Install useful plugins for debugging
ADD https://ci.viaversion.com/job/ViaVersion/lastSuccessfulBuild/artifact/jar/target/ViaVersion-2.0.2-SNAPSHOT.jar plugins/viaversion.jar
ADD https://dev.bukkit.org/projects/worldedit/files/2597538/download plugins/worldedit.jar

# Run the server with recommended flags from https://mcflags.emc.gs
EXPOSE 25565
CMD java -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:MaxGCPauseMillis=100 -XX:+DisableExplicitGC -XX:TargetSurvivorRatio=90 -XX:G1NewSizePercent=50 -XX:G1MaxNewSizePercent=80 -XX:G1MixedGCLiveThresholdPercent=35 -XX:+AlwaysPreTouch -XX:+ParallelRefProcEnabled -XX:+UseLargePagesInMetaspace -jar sportpaper.jar
