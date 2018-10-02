#!/bin/bash

rebootRequired() {
	echo '';
	read -p 'Reboot? [Y/n] ' -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Nn]$ ]]; then
		sudo reboot
	fi
}

menu() {
	echo ''
	echo '1) Menu 1'
	echo '2) Menu 2'
	echo '3) Menu 3'
	echo '0) Exit'
	read -p 'Enter your choice: ' choice

	case "$choice" in
		'1')
			echo 'Menu 1';
		;;
		'2')
		  echo 'Menu 2';
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
