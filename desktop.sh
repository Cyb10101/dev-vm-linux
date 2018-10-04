#!/bin/bash

pauseAnyKey() {
	read -n 1 -s -r -p 'Press any key to continue...'
	echo
}

installSoftware() {
	sudo apt -y install firefox
	echo
}

menu() {
	echo ''
	echo '1) XFCE4 Desktop'
	echo '2) Minimal Gnome Desktop'
  echo '3) XFCE4 Ubuntu Desktop'
  echo '4) Ubuntu Desktop (Recommended)'
  echo '5) Real Gnome Desktop'
	echo '0) Exit'
	read -p 'Enter your choice: ' choice

	case "$choice" in
		'1')
			sudo apt -y install xfce4

			echo "if [[ ! \${DISPLAY} && \${XDG_VTNR} -eq 1 ]]; then" >> /home/user/.bashrc
			echo "  exec startx" >> /home/user/.bashrc
			echo "fi" >> /home/user/.bashrc

			echo "if [[ ! \${DISPLAY} && \${XDG_VTNR} -eq 1 ]]; then" >> /home/user/.zshrc
			echo "  exec startx" >> /home/user/.zshrc
			echo "fi" >> /home/user/.zshrc

			installSoftware
			sudo reboot
		;;
		'2')
      # Minimal Gnome Desktop
      sudo apt -y install gnome-core
			installSoftware
      sudo reboot
		;;
		'3')
      # XFCE4 Desktop
      sudo apt -y install xubuntu-desktop
			installSoftware
      sudo reboot
		;;
    '4')
      # Ubuntu 18.04 & 16.04
      sudo apt -y install ubuntu-desktop
			installSoftware
      sudo reboot
		;;
    '5')
      # For the real Gnome Desktop
      sudo apt -y install gnome
			installSoftware
      sudo reboot
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

menu
