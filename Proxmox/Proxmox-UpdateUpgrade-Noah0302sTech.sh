#!/bin/bash
# Made by Noah0302sTech
# chmod +x Proxmox-UpdateUpgrade-Noah0302sTech.sh && bash Proxmox-UpdateUpgrade-Noah0302sTech.sh





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





#----- Update Packages
	start_spinner "Update Package-Listen..."
		apt update -y > /dev/null 2>&1
	stop_spinner $?
	echo
	echo



#----- Variables
	cronVariable="0 8 * * *"



#----- Prompt for custom values
	read -p "Passe den Cron-Job an [default 8 Uhr täglich: $cronVariable]: " input
	cronVariable=${input:-$cronVariable}
	echo
	echo



#----- Create Bash-File
	start_spinner "Erstelle Proxmox-Updater Bash-File..."
		touch /root/Proxmox-Updater.sh
		touch /root/Cron-Debug.txt
	stop_spinner $?

	#--- Echo Commands into Proxmox-Updater.sh
		echo "#!/bin/bash
# Made by Noah0302sTech

#Update
	apt update && apt dist-upgrade -y

#Debug
	echo "Proxmox-Updater Cron-Job ran @" >> /root/Proxmox/Cron-Debug.txt
	date >> /root/Proxmox/Cron-Debug.txt 
	echo '' >> /root/Proxmox/Cron-Debug.txt" > Proxmox-Updater.sh

	#--- Make Proxmox-Updater.sh executable
		start_spinner "Mache Proxmox-Updater.sh ausführbar..."
			chmod +x Proxmox-Updater.sh
		stop_spinner $?
	echo
	echo



#----- Create Crontab
	start_spinner "Erstelle Crontab..."
		touch /etc/cron.d/Proxmox-Updater-Noah0302sTech
		echo "#Daily Update && Upgrade for Proxmox by Noah0302sTech
$cronVariable root /root/Proxmox/Proxmox-Updater.sh" > /etc/cron.d/Proxmox-Updater-Noah0302sTech
	stop_spinner $?
	echo
	echo



#----- Move Bash Script
	start_spinner "Verschiebe Bash-Skripte..."
		mkdir /root/Proxmox
		mv /root/Proxmox-Updater.sh /root/Proxmox/Proxmox-Updater.sh
		mv /root/Cron-Debug.txt /root/Proxmox/Cron-Debug.txt
		mv /root/Proxmox-UpdateUpgrade-Noah0302sTech.sh /root/Proxmox/Proxmox-UpdateUpgrade-Noah0302sTech.sh
	stop_spinner $?
	echo
	echo