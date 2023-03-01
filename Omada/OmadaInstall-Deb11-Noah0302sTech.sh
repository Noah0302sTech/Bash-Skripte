#!/bin/bash
# Made by Noah0302sTech
# chmod +x OmadaInstall-Deb11-Noah0302sTech.sh && sudo ./OmadaInstall-Deb11-Noah0302sTech.sh



#----- Check for administrative privileges
  if [[ $EUID -ne 0 ]]; then
    echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
    exit 1
  fi



#--- Install Java
  echo "Installiere OpenJDK-8, bitte warten... "

  #--- Add sid main repo
    sudo echo "deb http://deb.debian.org/debian/ sid main" | sudo tee -a /etc/apt/sources.list > /dev/null 2>&1

  #--- Install OpenJDK-8
    sudo apt update > /dev/null 2>&1
    sudo apt install openjdk-8-jre-headless -y

  #--- Remove sid main repo
    sudo sed -i '\%^deb http://deb.debian.org/debian/ sid main%d' /etc/apt/sources.list > /dev/null 2>&1
    echo
  
  echo
  echo



#--- Install jsvc curl gnupg2
  echo "Installiere jsvc curl gnupg2, bitte warten... "

  #--- Refresh Packages
    sudo apt update > /dev/null 2>&1

  #--- Install jsvc curl gnupg2
    sudo apt install jsvc curl gnupg2 -y &> /dev/null &
      PID=$!
      i=1
      sp="/-\|"
      echo -n ' '
      while [ -d /proc/$PID ]
        do
        printf "\b${sp:i++%${#sp}:1}"
      done
      echo
      printf "\xE2\x9C\x94 \n"
    echo
  
  echo
  echo



#--- Install MongoDB
  echo "Installiere MongoDB, bitte warten... "

  #--- Add apt key
    curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -  > /dev/null 2>&1
  
  #--- Configure sources.list
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list > /dev/null 2>&1

  #--- Install Mongo-DB
    sudo apt update > /dev/null 2>&1
    sudo apt install mongodb-org -y &> /dev/null &
      PID=$!
      i=1
      sp="/-\|"
      echo -n ' '
      while [ -d /proc/$PID ]
        do
        printf "\b${sp:i++%${#sp}:1}"
      done
      echo
      printf "\xE2\x9C\x94 \n"
    echo

  #--- Enable Mongo-DB
    sudo systemctl enable mongod --now
    sudo systemctl status mongod
  
  echo
  echo



#--- Install Omada

  #--- Create directory
    sudo mkdir /home/$SUDO_USER/omada
    if [ -d /home/$SUDO_USER/omada ]; then
      cd /home/$SUDO_USER/omada
    else
      echo "Failed to create directory for Omada"
      exit 1
    fi
  
  #--- Prompt user for the Omada download URL or use the default if left blank
    read -p "Füge die Download-URL für Omada_SDN_Controller_vX.X.X_Linux_x64.deb hier ein (Leer für v5.8.4): " omada_url
    if [ -z "$omada_url" ]; then
      omada_url="https://static.tp-link.com/upload/software/2023/202301/20230130/Omada_SDN_Controller_v5.8.4_Linux_x64.deb"
    fi
    echo

    echo "Downloade Omada-Controller, bitte warten... "
    wget "$omada_url" &> /dev/null &
      PID=$!
      i=1
      sp="/-\|"
      echo -n ' '
      while [ -d /proc/$PID ]
        do
        printf "\b${sp:i++%${#sp}:1}"
      done
      echo
      printf "\xE2\x9C\x94 \n"
    echo
  
  #--- Installation
    echo "Installiere Omada-Controller, bitte warten... "
    
    sudo apt install ./Omada_SDN_Controller_*.deb

    echo
    echo