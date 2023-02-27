#!/bin/bash
# Made by Noah0302sTech
# chmod +x OmadaInstall-Deb11-Noah0302sTech.sh && sudo ./OmadaInstall-Deb11-Noah0302sTech.sh

#--- Check if the script is running as root or with admin privileges
  if [ "$EUID" -ne 0 ]; then
    echo "Please run the script as root or with admin privileges"
    exit 1
  fi

#--- Install Java
  sudo echo "deb http://deb.debian.org/debian/ sid main" | sudo tee -a /etc/apt/sources.list
  sudo apt update && sudo apt install openjdk-8-jre-headless -y
  sudo sed -i '\%^deb http://deb.debian.org/debian/ sid main%d' /etc/apt/sources.list

#--- Install MongoDB
  sudo apt update && sudo apt install jsvc curl gnupg2 -y
  curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
  sudo apt update && sudo apt install mongodb-org -y
  sudo systemctl enable mongod --now
  sudo systemctl status mongod

#--- Install Omada
  sudo mkdir /home/$SUDO_USER/omada
  if [ -d /home/$SUDO_USER/omada ]; then
    cd /home/$SUDO_USER/omada
  else
    echo "Failed to create directory for Omada"
    exit 1
  fi
  #--- Prompt user for the Omada download URL or use the default if left blank
  echo
  echo
  echo
  read -p "Enter the download URL for Omada (Leave blank for v5.8.4): " omada_url
  if [ -z "$omada_url" ]; then
      omada_url="https://static.tp-link.com/upload/software/2023/202301/20230130/Omada_SDN_Controller_v5.8.4_Linux_x64.deb"
  fi
  wget "$omada_url"
  #--- Installation
  sudo apt install ./Omada_SDN_Controller_*.deb