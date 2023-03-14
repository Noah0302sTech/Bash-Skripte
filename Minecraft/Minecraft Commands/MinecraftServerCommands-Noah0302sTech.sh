#!/bin/bash
#   Made by Noah0302sTech
#   chmod +x Variables-MC-Commands.sh && sudo ./Variables-MC-Commands.sh

#----- Check for administrative privileges
  if [[ $EUID -ne 0 ]]; then
    echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
    exit 1
  fi



#----- Set default values
    COMMAND="say Hallo!"



#----- Prompt for custom values
    read -p "Gib deinem MC-Server-Command ein [default: $COMMAND]: " input
    COMMAND=${input:-$COMMAND}



#----- Execute
    sudo echo $COMMAND > /run/minecraftserver.stdin