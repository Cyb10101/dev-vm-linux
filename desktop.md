### I need a desktop!

No you don't... Maybe not recommended.

For those who need a desktop on the server, you can install one of the following packages.

Run desktop installation:

```Shell
/home/user/dev-vm-linux/desktop.sh
```

### Autologin

Forces auto login. Maybe not recommended.

```Shell
sudo systemctl edit getty@tty1
```

Add in "getty@tty1" file:

```ini
[Service]
Type=idle
ExecStart=
ExecStart=-/sbin/agetty --autologin user --noclear %I 38400 linux
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
sudo vim /etc/acpi/powerbtn.sh sudo vim /etc/acpi/powerbtn.sh
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
