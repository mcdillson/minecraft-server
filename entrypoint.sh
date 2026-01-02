#!/bin/sh -e

# Add the default mods, plugins and world
if [ "${WORLD_BACKUP}" != "" ]; then
  if [ ! "$(ls -A /minecraft/worlds)" ]; then 
    echo "Installing default world ${WORLD_BACKUP}"
    
    if [ ! -d "/minecraft/worlds" ]; then
      mkdir /minecraft/worlds
    fi
   
    cd /tmp && \
      wget -O world.tar.gz ${WORLD_BACKUP} && \
      tar -C /minecraft/worlds -xzf world.tar.gz && \
      rm world.tar.gz

    # Create symlinks for the world, world_nether, and world_the_end
    if [ -d "/minecraft/worlds/world" ]; then
      ln -s /minecraft/worlds/world /minecraft/world
    fi
    
    if [ -d "/minecraft/worlds/world_nether" ]; then
      ln -s /minecraft/worlds/world_nether /minecraft/world_nether
    fi
    
    if [ -d "/minecraft/worlds/world_the_end" ]; then
      ln -s /minecraft/worlds/world_the_end /minecraft/world_the_end
    fi
  fi
fi

if [ "${MODS_BACKUP}" != "" ]; then 
  if [ ! "$(ls -A /minecraft/mods)" ]; then 
    echo "Installing default mods ${MODS_BACKUP}"
    
    if [ ! -d "/minecraft/mods" ]; then
      mkdir /minecraft/mods
    fi

    cd /tmp && \
      wget -O mods.tar.gz ${MODS_BACKUP} && \
      tar -C /minecraft/mods -xzf mods.tar.gz && \
      rm mods.tar.gz
  fi
fi

if [ "${PLUGINS_BACKUP}" != "" ]; then 
  if [ ! "$(ls -A /minecraft/plugins)" ]; then 
    echo "Installing default plugins ${PLUGINS_BACKUP}"
    
    if [ ! -d "/minecraft/plugins" ]; then
      mkdir /minecraft/plugins
    fi

    cd /tmp && \
      wget -O plugins.tar.gz ${PLUGINS_BACKUP} && \
      tar -C /minecraft/plugins -xzf plugins.tar.gz && \
      rm plugins.tar.gz
  fi
fi

# Add config items which are in the main minecraft folder from config so that 
# they can persist across launches
if [ ! -d "/minecraft/config" ]; then
  mkdir /minecraft/config
fi

# Creating default config files
if [ ! -f "/minecraft/config/banned-ips.json" ]; then
  echo "[]" >> /minecraft/config/banned-ips.json
fi

if [ ! -f "/minecraft/config/banned-players.json" ]; then
  echo "[]" >> /minecraft/config/banned-players.json
fi

if [ ! -f "/minecraft/config/usercache.json" ]; then
  echo "[]" >> /minecraft/config/usercache.json
fi

if [ ! -f "/minecraft/config/whitelist.json" ]; then
  echo "[]" >> /minecraft/config/whitelist.json
fi

if [ ! -f "/minecraft/config/bukkit.yml" ]; then
  cat <<EOF > /minecraft/config/bukkit.yml
    settings:
      allow-end: true
      warn-on-overload: true
      permissions-file: permissions.yml
      update-folder: update
      plugin-profiling: false
      connection-throttle: 4000
      query-plugins: true
      deprecated-verbose: default
      shutdown-message: Server closed
      minimum-api: none
    spawn-limits:
      monsters: 70
      animals: 10
      water-animals: 5
      water-ambient: 20
      ambient: 15
    chunk-gc:
      period-in-ticks: 600
    ticks-per:
      animal-spawns: 400
      monster-spawns: 1
      water-spawns: 1
      water-ambient-spawns: 1
      ambient-spawns: 1
      autosave: 6000
    aliases: now-in-commands.yml
EOF
fi

# Create symlinks for config files
[ -f /minecraft/banned-ips.json ] || ln -s /minecraft/config/banned-ips.json /minecraft/banned-ips.json
[ -f /minecraft/banned-players.json ] || ln -s /minecraft/config/banned-players.json /minecraft/banned-players.json
[ -f /minecraft/usercache.json ] || ln -s /minecraft/config/usercache.json /minecraft/usercache.json
[ -f /minecraft/whitelist.json ] || ln -s /minecraft/config/whitelist.json /minecraft/whitelist.json
[ -f /minecraft/ops.json ] || ln -s /minecraft/config/ops.json /minecraft/ops.json
[ -f /minecraft/bukkit.yml ] || ln -s /minecraft/config/bukkit.yml /minecraft/bukkit.yml

# Configure the properties
eval "echo \"$(cat /server.properties)\"" > /minecraft/server.properties

# Start the server
cd /minecraft
java -Xmx${JAVA_MEMORY} -Xms${JAVA_MEMORY} -Dfml.queryResult=confirm -jar fabric-server-launch.jar nogui
