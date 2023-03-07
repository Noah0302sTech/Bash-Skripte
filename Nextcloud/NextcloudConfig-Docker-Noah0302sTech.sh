#!/bin/bash
# Made by Noah0302sTech
# chmod +x NextcloudConfig-Noah0302sTech.sh && sudo ./NextcloudConfig-Noah0302sTech.sh



#----- Check for administrative privileges
  if [[ $EUID -ne 0 ]]; then
    echo "Das Skript muss mit Admin-Privilegien ausgeführt werden! (sudo)"
    exit 1
  fi



#----- Source of Spinner-Function: https://github.com/tlatsas/bash-spinner
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





#----- Change Config
    sudo nano /var/lib/docker/volumes/nextcloud_nextcloud_data/_data/config/config.php



#----- Restart Docker
    while true; do
        read -p "Möchtest du die Docker-Container jetzt neustarten [empfohlen]? Y/N: " yn
        case $yn in
            [Yy]* ) start_spinner "Starte Nextcloud-Server... "
                        && sudo docker restart nextcloud_nextcloud_1 > /dev/null 2>&1
                        && sudo docker restart nextcloud_db_1 > /dev/null 2>&1
                    stop_spinner $?; break;;
            [Nn]* ) exit;;
            * ) echo "Bitte gib Y/y für Ja, oder N/n für Nein ein." && echo;;
        esac
    done
    echo
    sudo docker ps
    
    echo
    echo