#!/bin/bash
# Made by Noah0302sTech
# chmod +x OmadaInstall-Deb11-Noah0302sTech.sh && sudo ./OmadaInstall-Deb11-Noah0302sTech.sh



#----- Check for administrative privileges
  if [[ $EUID -ne 0 ]]; then
    echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
    exit 1
  fi

#----- Source of spinner function: https://github.com/tlatsas/bash-spinner
    function _spinner() {
        # $1 start/stop
        #
        # on start: $2 display message
        # on stop : $2 process exit status
        #           $3 spinner function pid (supplied from stop_spinner)

        local on_success="DONE"
        local on_fail="FAIL"
        local white="\e[1;37m"
        local green="\e[1;32m"
        local red="\e[1;31m"
        local nc="\e[0m"

        case $1 in
            start)
                # calculate the column where spinner and status msg will be displayed
                let column=$(tput cols)-${#2}-8
                # display message and position the cursor in $column column
                echo -ne ${2}
                printf "%${column}s"

                # start spinner
                i=1
                sp='\|/-'
                delay=${SPINNER_DELAY:-0.15}

                while :
                do
                    printf "\b${sp:i++%${#sp}:1}"
                    sleep $delay
                done
                ;;
            stop)
                if [[ -z ${3} ]]; then
                    echo "spinner is not running.."
                    exit 1
                fi

                kill $3 > /dev/null 2>&1

                # inform the user uppon success or failure
                echo -en "\b["
                if [[ $2 -eq 0 ]]; then
                    echo -en "${green}${on_success}${nc}"
                else
                    echo -en "${red}${on_fail}${nc}"
                fi
                echo -e "]"
                ;;
            *)
                echo "invalid argument, try {start/stop}"
                exit 1
                ;;
        esac
    }

    function start_spinner {
        # $1 : msg to display
        _spinner "start" "${1}" &
        # set global spinner pid
        _sp_pid=$!
        disown
    }

    function stop_spinner {
        # $1 : command exit status
        _spinner "stop" $1 $_sp_pid
        unset _sp_pid
    }






#----- Install Java
  #--- Add sid main repo
    start_spinner "Füge Sid-Main-Repo hinzu, bitte warten..."
      sudo echo "deb http://deb.debian.org/debian/ sid main" | sudo tee -a /etc/apt/sources.list > /dev/null 2>&1
    stop_spinner $?

  #--- Refresh Packages
    start_spinner "Aktualisiere Package-Listen, bitte warten..."
      sudo apt update > /dev/null 2>&1
    stop_spinner $?

  #--- Install OpenJDK-8
    sudo apt install openjdk-8-jre-headless -y

  #--- Remove sid main repo
    start_spinner "Entferne Sid-Main-Repo, bitte warten..."
      sudo sed -i '\%^deb http://deb.debian.org/debian/ sid main%d' /etc/apt/sources.list > /dev/null 2>&1
    stop_spinner $?
    
  echo
  echo



#----- Install jsvc curl gnupg2
  #--- Refresh Packages
    start_spinner "Aktualisiere Package-Listen, bitte warten..."
      sudo apt update > /dev/null 2>&1
    stop_spinner $?

  #--- Install jsvc curl gnupg2
    start_spinner "Installiere jsvc curl gnupg2, bitte warten..."
      sudo apt install jsvc curl gnupg2 -y > /dev/null 2>&1
    stop_spinner $?

  echo
  echo



#----- Install MongoDB
  #--- Add apt key
    start_spinner "Installiere MongoDB, bitte warten..."
      curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -  > /dev/null 2>&1
    stop_spinner $?

  #--- Configure sources.list
    start_spinner "Installiere MongoDB, bitte warten..."
      echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list > /dev/null 2>&1
    stop_spinner $?

  #--- Refresh Packages
    start_spinner "Aktualisiere Package-Listen, bitte warten..."
      sudo apt update > /dev/null 2>&1
    stop_spinner $?

  #--- Install MongoDB
    start_spinner "Installiere Mongo-DB, bitte warten..."
      sudo apt install mongodb-org -y > /dev/null 2>&1
    stop_spinner $?

  #--- Enable MongoDB and show Status
    start_spinner "Installiere Mongo-DB, bitte warten..."
      sudo systemctl enable mongod --now
      sudo systemctl status mongod
    stop_spinner $?

  echo
  echo



#----- Install Omada
  #--- Create directory
    start_spinner "Erstelle Omada-Directory, bitte warten..."
      sudo mkdir /home/$SUDO_USER/omada > /dev/null 2>&1
      if [ -d /home/$SUDO_USER/omada ]; then
        cd /home/$SUDO_USER/omada
      else
        echo "Failed to create directory for Omada"
        exit 1
      fi
    stop_spinner $?
    echo

  #--- Prompt user for the Omada download URL or use the default if left blank
    read -p "Füge die Download-URL für Omada_SDN_Controller_vX.X.X_Linux_x64.deb hier ein (Leer für v5.9.9): " omada_url
    if [ -z "$omada_url" ]; then
      omada_url="https://static.tp-link.com/upload/software/2023/202302/20230227/Omada_SDN_Controller_v5.9.9_Linux_x64.deb"
    fi
    echo "Gewählte Version: $omada_url"
    echo

  #--- Download selcted Omada-Version
    start_spinner "Downloade Omada-Controller, bitte warten..."
      wget "$omada_url" > /dev/null 2>&1
    stop_spinner $?
    echo

  #--- Install downloaded Omada-Version
    sudo apt install ./Omada_SDN_Controller_*.deb

  echo
  echo