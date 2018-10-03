## VirtualBox - Create a new virtual machine

* Install VirtualBox: https://virtualbox.org/

VirtalBox > New > (Expert Mode)

* Name: UbuntuDev
* Type: Linux
* Version: Ubuntu (64 bit)
* Memory size: 4096 MB
* Hard disk: No - Do not add a virtual hard disk

VirtualBox > Settings

* System
  - Motherboard > Boot Order: Optical, Hard Disk
  - Processor > CPU: 4 (Maximum of green)
* Storage (Expert mode)
  - SATA Port 0, Hard disk, File location: System, 80 GB, VDMK, Dynamically allocated
  - SATA Port 2, Compact Disc, Insert operating system
* Audio > Enable Audio: false
* Network
  - Adapter 1, NAT
  - Adapter 2, Bridged Adapter, eth1 (Your network device)


### Download Ubuntu
https://ubuntu.com/

### Install Ubuntu Server 16.04

Note: Ubuntu 18.04, has no PHP 5.* and docker ready.

* Language: English
* Install Ubuntu Server

* Language: English
* Country: United States
* Optional: Detect Keyboard Layout
* Select Primary Network interface

* Hostname: dev-vm
* Full name: user
* Username: user
* Passwort: user

* Encrypt home directory: No (Your preference)
* Time zone: Europe/Berlin (Your preference)
* Partition method: Guided - use the entire disk
  - SCSI1 (0,0,0) (sda) - 80 GB ATA VBOX HARDDISK

* HTTP proxy: (empty)
* No automatic updates
* Software
  - standard system utilities
  - OpenSSH server
* Install GRUB boot loader = Yes
* Reboot

### Install Ubuntu Server 18.04

Note: Ubuntu 18.04, has no PHP 5.* and docker ready.

* Page 1:
  - Language: English
* Page 2: (Your preference -> Identify keyboard)
  - Layout: English (US)
  - Variant: English (US)
* Page 3: (Install Ubuntu)
* Page 4:
  - Network configuration
  - Proxy address: (empty)
* Page 5: (bypassed)
* Page 6:
  - Use an Entire Disk
  - VBOX_HARDDISK_...

  * Your name: user
  * Your Server's name: dev-vm
  * Username: user
  * Passwort: user
* Page 7: (bypassed)
* Page 8: (Installation running)
* Page 9: (Reboot)

## Procceed the installation

Set password for root account with password: root

```Shell
sudo passwd root
```

### Visudo: No password for user

```Shell
sudo visudo
```

Append to end in visudo file:

```text
user ALL=(ALL) NOPASSWD: ALL
```

Reboot system.

### Ubuntu 16.04 Server: Configure network interfaces

```Shell
ip a
sudo vim /etc/network/interfaces
```

File: interfaces

```Shell
# The loopback network interface
auto lo
iface lo inet loopback

# Network 1 (NAT)
auto enp0s3
iface enp0s3 inet dhcp

# Network 2 (Bridged Adapter)
auto enp0s8
iface enp0s8 inet dhcp

# Network 3 (Host-only Adapter)
#auto enp0s9
#iface enp0s9 inet dhcp
```

Restart network interfaces.

```Shell
sudo ifdown -a && sudo ifup -a
```

### Repository

Install Git & clone repository.

```Shell
sudo apt -y install git
git clone https://github.com/Cyb10101/dev-vm-linux.git /home/user/dev-vm-linux
```

### Install

Run installation.

```Shell
/home/user/dev-vm-linux/create.sh
```

* Ubuntu 18.04: Configuring console-setup: UTF-8

@todo desktop
```Shell
sudo apt -y install gparted meld nautilus-compare

mkdir ~/Templates
touch '~/Templates/Empty Document Patch'
```

### Optional: Pretest PhpBrew Versions and update PHP
@todo was damit machen?
In the script update the PHP versions for the installation.

* Create Snapshot, install PHP, install PhpBrew
* Query and update available PHP versions
* Reset snapshot

```Shell
sudo apt -y install php

# Install PhpBrew

# Check available versions
phpbrew known

# PHP Versionen aktualisieren
find . -type d -name '.git' -prune -o -type f -print -exec sed -i '' \
    -e 's/7\.2\.5/7\.2\.10/g' \
    -e 's/7\.1\.17/7\.1\.22/g' \
    -e 's/7\.0\.30/7\.0\.32/g' \
    -e 's/5\.6\.36/5\.6\.38/g' \
    {} \;

mv etc/nginx/snippets/php-7.2.5.conf etc/nginx/snippets/php-7.2.10.conf
mv etc/nginx/snippets/php-7.1.17.conf etc/nginx/snippets/php-7.1.22.conf
mv etc/nginx/snippets/php-7.0.30.conf etc/nginx/snippets/php-7.0.32.conf
mv etc/nginx/snippets/php-5.6.36.conf etc/nginx/snippets/php-5.6.38.conf
```

## Ubuntu Desktop: Configure operating system
@todo later or remove
```Shell
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false

gsettings set org.gtk.Settings.FileChooser show-hidden true
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
gsettings set org.gnome.nautilus.list-view default-visible-columns "['name', 'owner', 'group', 'permissions']"
```

### Ubuntu 18.04 Desktop
@todo later or remove
```Shell
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
```

### Ubuntu 16.04 Desktop
@todo later or remove
```Shell
gsettings set org.gnome.desktop.interface menus-have-icons true
gsettings set org.gnome.desktop.interface buttons-have-icons true
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set com.canonical.indicator.session show-real-name-on-panel true
gsettings set com.canonical.Unity integrated-menus true
```

* Ubuntu 16.04 Desktop: System Settings > Security & Privacy > Files & Applications > Record file and application usage = Off

### Optional: Watcher for changes to the configuration
@todo later or remove

For further configuration, you can use these tools.

```Shell
dconf watch /
sudo apt -y install dconf-editor
gsettings list-recursively | grep search
```

## Message of the day - Keep me from working
@todo
Yes, you wan't it! Your boss would kill you, but your soul thanks you.
Each new Terminal you opening on desktop or with ssh, you get a new message.


Show which fortunes are available and configure it at function "terminalMotd" in .shell-methods file:

```Shell
ls /usr/share/games/fortunes
vim /home/user/.shell-methods
```

Enable "terminalMotd" in bash & zsh:

```Shell
vim ~/.bashrc && sudo vim /root/.bashrc
vim ~/.zshrc && sudo vim /root/.zshrc
```

### Ubuntu Desktop
@todo remove?
Configure Dnsmasq and NetworkManager.

```Shell
sudo sh -c 'echo "address=/.vm/127.0.0.1" >> /etc/NetworkManager/dnsmasq.d/development'

# sudo apt install resolvconf
sudo vim /etc/NetworkManager/NetworkManager.conf
```

Append to file: /etc/NetworkManager/NetworkManager.conf

```ini
[main]
dns=dnsmasq
```

```Shell
sudo systemctl restart network-manager
sudo resolvconf -u
```

## Ubuntu Desktop: Firefox Browser
@todo firefox
* Activate Bookmarks Toolbar

* MailCachter
    - http://127.0.0.1:1080/

* Nginx Localhost
    - http://127.0.0.1/

* Apache Localhost
    - http://127.0.0.1:8080/

* TYPO3-Demo (Nginx)
    - http://nginx-demo.vm

* TYPO3-Demo (Apache)
    - http://apache-demo.vm

## Samba
@todo samba
Configure Samba /etc/samba/smb.conf:

```Text
[global]
   security = user
   allow insecure wide links = yes
   workgroup = Company

[www]
  comment = web path
  path = /var/www
  public = no
  writeable = yes
  guest ok = no
  browseable = yes
  valid users = user
  create mask = 0664
  directory mask = 0750
  follow symlinks = yes
  wide links = yes
  force user = user
  force group = user
```

## Ubuntu Desktop: HeidiSQL
@todo remove or else
* https://www.heidisql.com/
* https://www.chiark.greenend.org.uk/~sgtatham/putty/

```Shell
wget -O ~/Downloads/HeidiSQL.exe https://www.heidisql.com/installers/HeidiSQL_9.5.0.5196_Setup.exe
wget -O ~/Downloads/putty.msi https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.70-installer.msi

sudo apt -y install playonlinux
```

Open PlayOnLinux and create a new virtual drive.

* Tools > Manage Wine versions > Install latest 64 bit Wine version (current: 3.14)

* Configure > New > 64 bit latest Wine Version (Container name: HeidiSQL)
* Select Container
	- Wine > Configure Wine > Application > Windows Version: Windows XP
    - Miscellaneous > Run a .exe file in this virtual drive > Install HeidiSQL & Putty
	- General > Make a new shortcut from this virtual drive > heidisql.exe > Shortcut name: HeidiSQL

Remove HeidiSQL created Shortcut and convert icon from executable.

```Shell
rm ~/Downloads/HeidiSQL.exe ~/Desktop/HeidiSQL.desktop ~/Desktop/HeidiSQL.lnk ~/Downloads/putty.msi

# Maybe Bug on Ubuntu 16.04
wrestool -x -t14 --name=MAINICON ~/.PlayOnLinux/wineprefix/HeidiSQL/drive_c/Program\ Files/HeidiSQL/heidisql.exe > ~/.PlayOnLinux/wineprefix/HeidiSQL/drive_c/Program\ Files/HeidiSQL/heidisql.ico
```

Open HeidiSQL and create new session.

* Session Name: Localhost
* Hostname / IP: 127.0.0.1
* User: root
* Password: root
* Port: 3306

Connect Server Localhost in HeidiSQL and configure it.

* Tools > Preferences > SQL > Editor font: Liberation Mono, 10pt

## Ubuntu 16.04 Desktop: Do not display a dialog box on ACPI shutdown
@todo desktop
```Shell
sudo vim /etc/acpi/powerbtn.sh
```

At the top of the file:

```Shell
/sbin/shutdown -h now 'Power button pressed' && exit 0
```

### Optional Ubuntu Desktop: Set Wallpaper
@todo desktop
Can of course also be configured via settings.

```Shell
ls /home/user/Pictures

gsettings set org.gnome.desktop.background picture-uri "file:///home/user/Pictures/wallpaper.jpg"
gsettings set org.gnome.desktop.background picture-options 'zoom'
```

Ubuntu 18.04: Additionally for lock screen

```Shell
gsettings set org.gnome.desktop.screensaver picture-uri "file:///home/user/Pictures/wallpaper.jpg"
gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
```

## Optional: Change keyboard layout
@todo was damit machen?
Example:

* Generic 105-key keyboard
* English (US)

```Shell
sudo dpkg-reconfigure keyboard-configuration
```

## Recommended: Shrink hard disk for export

Boot with a Ubuntu Live ISO and fill empty space on hard disk with zeros.

```Shell
sudo su
apt install zerofree
blkid
zerofree -v /dev/sda1
poweroff
```

## Virtualbox export

* Expert mode
* Virtualbox > File > Export Appliance
  - Open Virtualization Format 2.0

## Virtualbox import

To import a OVA file and configure the virtual machine see file [usage.md](usage.md).
