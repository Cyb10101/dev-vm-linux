#!/bin/bash

rebootRequired() {
	echo '';
	read -p 'Reboot? [Y/n] ' -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Nn]$ ]]; then
		sudo reboot
	fi
}

messageOfTheDayUser() {
	echo '';
	read -p 'Message of the day for user? [Y/n] ' -n 1 -r
	echo '';
	if [[ ! $REPLY =~ ^[Nn]$ ]]; then
		sed -i 's/^#terminalMotd/terminalMotd/' /home/user/.bashrc
		sed -i 's/^#terminalMotd/terminalMotd/' /home/user/.zshrc
	else
		sed -i 's/^terminalMotd/#terminalMotd/' /home/user/.bashrc
		sed -i 's/^terminalMotd/#terminalMotd/' /home/user/.zshrc
	fi
}

messageOfTheDayRoot() {
	echo '';
	read -p 'Message of the day for root? [y/N] ' -n 1 -r
	echo '';
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		sudo sed -i 's/^#terminalMotd/terminalMotd/' /root/.bashrc
		sudo sed -i 's/^#terminalMotd/terminalMotd/' /root/.zshrc
	else
		sudo sed -i 's/^terminalMotd/#terminalMotd/' /root/.bashrc
		sudo sed -i 's/^terminalMotd/#terminalMotd/' /root/.zshrc
	fi
}

menu() {
	echo ''
	echo '1) Menu 1'
	echo '2) Message of the day'
	echo '3) Menu 3'
	echo '0) Exit'
	read -p 'Enter your choice: ' choice

	case "$choice" in
		'1')
			echo 'Menu 1';
		;;
		'2')
			messageOfTheDayUser
			messageOfTheDayRoot
		;;
		'3')
			echo 'Menu 3';
		;;

		'0')
			exit 0
		;;
		*)
			echo 'Wrong choice... Please try again.'
			menu
		;;
	esac
}

if [ -f /home/user/.phpbrew/bashrc ]; then
	source /home/user/.phpbrew/bashrc
	phpbrew use php-7.2.10
fi
menu
