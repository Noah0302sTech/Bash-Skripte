#!/bin/bash
# Made by Noah0302sTech
# chmod +x AutomountNFS-Deb11-Noah0302sTech.sh && sudo bash AutomountNFS-Deb11-Noah0302sTech.sh

#	TODO:	Add Folder Structure
#			Change Layout
#			Change Indentation from Spaces to Tabs
#			

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





#----- Update Packages
	start_spinner "Update Package-Listen..."
    	apt update -y > /dev/null 2>&1
	stop_spinner $?
	echo
	echo


#----- Set Variables
    mountname=/mnt/NFS-Share
    nfsserverip=192.168.6.x
    nfsexport=/mnt/Pool01/nfsExportName



#----- Prompt for custom values
    read -p "Gib den lokalen Pfad für den NFS-Mount [default: $mountname]: " input
    mountname=${input:-$mountname}
    read -p "Gib die IP deines NFS-Servers ein [default: $nfsserverip]: " input
    nfsserverip=${input:-$nfsserverip}
    read -p "Gib den Server-Pfad des NFS-Exports ein [default: $nfsexport]: " input
    nfsexport=${input:-$nfsexport}
    echo
    echo



#----- Erstelle Mount Verzeichnis (Lokal)
    start_spinner "Erstelle Mount Verzeichnis (Lokal)..."
        mkdir -p $mountname
    stop_spinner $?
    echo
    echo



#----- Mounte NFS-Share
    start_spinner "Mounte NFS-Share..."
        mount $nfsserverip:$nfsexport  $mountname
    stop_spinner $?
    echo
    echo



#----- Passe FSTAB an
    start_spinner "Passe FSTab an..."
        echo "

#NFS Mount (Noah0302sTech)
$nfsserverip:$nfsexport  $mountname nfs nfsvers=3,defaults,_netdev 0 0" >> /etc/fstab
    stop_spinner $?
    echo
    echo