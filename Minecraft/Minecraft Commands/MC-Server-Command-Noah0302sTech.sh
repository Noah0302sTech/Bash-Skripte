#!/bin/bash
#   Made by Noah0302sTech
#   chmod +x MC-Server-Command-Noah0302sTech.sh && sudo ./MC-Server-Command-Noah0302sTech.sh

#----- Check for administrative privileges
  if [[ $EUID -ne 0 ]]; then
    echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
    exit 1
  fi





#----- Set Variable values
    command="$@"



#----- Check if Input is empty
    if [ ! -z "$command" -a "$command" != " " ];
      then
          command="$@"
      else
          #----- Prompt for custom values
              command="say Hallo!"
              read -p "Gib deinen MC-Server-command ein [default: $command]: " input
              command=${input:-$command}
    fi



#----- Execute
              sudo echo $command > /run/minecraftserver.stdin