#!/bin/bash

pauseAnyKey() {
	read -n 1 -s -r -p 'Press any key to continue...'
	echo
}

installSoftware() {
	sudo apt -y install firefox gparted meld nautilus-compare
}

createTemplates() {
	mkdir ~/Templates
	touch '~/Templates/Empty Document Patch'
}

configureUbuntu() {
	gsettings set org.gnome.desktop.session idle-delay 0
	gsettings set org.gnome.desktop.screensaver lock-enabled false
	gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false

	gsettings set org.gtk.Settings.FileChooser show-hidden true
	gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
	gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
	gsettings set org.gnome.nautilus.list-view default-visible-columns "['name', 'owner', 'group', 'permissions']"

	if [[ $(lsb_release -rs) == '18.04' ]]; then
		gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
		gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
	fi;

	if [[ $(lsb_release -rs) == '16.04' ]]; then
		gsettings set org.gnome.desktop.interface menus-have-icons true
		gsettings set org.gnome.desktop.interface buttons-have-icons true
		gsettings set org.gnome.desktop.interface clock-show-date true
		gsettings set com.canonical.indicator.session show-real-name-on-panel true
		gsettings set com.canonical.Unity integrated-menus true
	fi;
}

configureDnsmasqNetworkManager() {
  sudo sh -c 'echo "address=/.vm/127.0.0.1" >> /etc/NetworkManager/dnsmasq.d/development'

  # sudo apt install resolvconf
  sudo vim /etc/NetworkManager/NetworkManager.conf

  sudo crudini --set /etc/NetworkManager/NetworkManager.conf 'main' 'dns' 'dnsmasq'

  sudo systemctl restart network-manager
  sudo resolvconf -u
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
			createTemplates
			configureUbuntu
			configureDnsmasqNetworkManager
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
