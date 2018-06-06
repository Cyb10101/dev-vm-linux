## Virtualbox import

* Virtualbox > Datei > Appliance importieren
  - CPU: 4 (Maximale von grün)
  - RAM: 2048 oder 4096 MB

* Allgemein > Erweitert > Sicherungspunkte > verschieben
* Massenspeicher > Festplatte 2 erstellen > Sata 1 > VMDK, dynamisch alloziert, Max available size, Name: Data
* Netzwerk konfigurieren
* Virtualbox Extension Pack installieren

## HDD2 - GParted
* Startmenü > GParted
* Device > Create Partition Table > GPT
* Partition > New
    - File system: ext4
    - Label: Data

* Startmenü > Terminal

```Shell
sudo mkdir /mnt/data
sudo blkid | grep sdb

sudo gedit /etc/fstab
```

* Datei fstab anpassen

```Text
UUID=288132af-be1e-4a3a-a2b6-1210c9816f50 /mnt/data               ext4    errors=remount-ro 0       1
```

* Startmenü > Terminal

```Shell
sudo mount /mnt/data
sudo chmod 777 /mnt/data
```

### HDD2 - Move Webserver

```Shell
sudo mkdir -p /mnt/data/var/www
sudo chown -R user:user /mnt/data/var
sudo chmod 775 /mnt/data/var/www
sudo chmod g+s /mnt/data/var/www

sudo mv /var/www/!(.|..) /mnt/data/var/www/
sudo rmdir /var/www
sudo ln -s /mnt/data/var/www /var/
```

### HDD2 - Move MySQL

```Shell
sudo service mysql stop
sudo mkdir -p /mnt/data/var/lib
sudo mv /var/lib/mysql /mnt/data/var/lib/
sudo ln -s /mnt/data/var/lib/mysql /var/lib/mysql

sudo gedit /etc/apparmor.d/tunables/alias
```

* Datei alias anpassen

```Text
alias /var/lib/mysql/ -> /mnt/data/var/lib/mysql/,
```

```Shell
sudo service apparmor restart
sudo service mysql start
```

## Virtualbox import - Konfigurieren

### SSH Key generieren (Eigene E-Mail eintragen)

```Shell
ssh-keygen -t rsa -b 4096 -C 'user@example.org'
```

### Convert SSH Key to Putty Key
Ist nacher erreichbar über Windows Freigabe, zum Beispiel für Putty oder HeidiSQL.

```Shell
puttygen /home/user/.ssh/id_rsa -o /var/www/id_rsa.ppk
```

### Git konfigurieren

Eigener Name & E-Mail eintragen.

```Shell
git config --global user.name 'Your Name'
git config --global user.email 'user@example.org'
```

### Development Context (User & Root)

Suche nach "Development/YourName" und ersetze es in eigenen Namen.

```Shell
sudo gedit /etc/apache2/conf-available/macro-virtual-host-defaults.conf
sudo gedit /etc/nginx/snippets/fastcgi-php.conf
```

## Add enviroment variables

Ersetze "Development/YourName" mit eigenen Namen.

```Shell
sudo sh -c 'echo "TYPO3_CONTEXT=Development/YourName" >> /etc/environment'
sudo sh -c 'echo "FLOW_CONTEXT=Development/YourName" >> /etc/environment'
sudo sh -c 'echo "WWW_CONTEXT=Development/YourName" >> /etc/environment'
```

### Domain setzen
Suche nach "vm00.example.org" und ersetze es in deiner Domain.

```Shell
find /etc/apache2/sites-available /etc/nginx/sites-available -type f -exec sed -i '' \
    -e 's/vm00\.example\.org/vm00\.company\.de/g' \
    -e 's/vm00\\\.example\\\.org/vm00\\\.company\\\.de/g' \
    {} \;

sudo apache2ctl configtest && sudo systemctl restart apache2
sudo nginx -t && sudo systemctl restart nginx
```

### Hostname setzen
Suche nach dev-vm" und ersetze es in deinem Namen.

Erlaubt: a-z 0-9 - (Bindestrich)

Großschreibung verzichten! Zum Beispiel: dev-your-name

```Shell
sudo gedit /etc/hostname
sudo gedit /etc/hosts
sudo gedit /etc/apache2/conf-available/server-name.conf
```

### Optional: Set static IP in network configuration

```Shell
ip a
sudo gedit /etc/network/interfaces
```

* Datei interfaces anpassen (unten drunter dran hängen)

```text
# Localhost configuration
auto lo
iface lo inet loopback

# Network card eth0 configuration (eth0 & ip anpassen)
auto enp0s8
iface enp0s8 inet static
	address 192.168.178.50
	netmask 255.255.255.0
	gateway 192.168.178.1
```

* Netzwerkkarte neu verbinden (Im Zweifelfall reboot)

```Shell
sudo ifdown -a && sudo ifup -a
```

### Optional: Install Software

 * https://atom.io/

```Shell
sudo apt -y install terminator
```

### Optional: Login Shell dauerhaft wechseln
Welchsel von "bash" zu "zsh" für den aktuellen Benutzer.

```Shell
chsh -s $(which zsh)
# chsh -s $(which bash)
```

### Optional: Switch from MailCachter to Fakemail
Nicht empfehlenswert, aber möglich.

```Shell
gedit /home/user/.phpbrew/php/php-7.2.5/etc/php.ini
gedit /home/user/.phpbrew/php/php-7.1.17/etc/php.ini
gedit /home/user/.phpbrew/php/php-7.0.30/etc/php.ini
gedit /home/user/.phpbrew/php/php-5.6.36/etc/php.ini
gedit /home/user/.phpbrew/php/php-5.5.38/etc/php.ini
gedit /home/user/.phpbrew/php/php-5.4.45/etc/php.ini

# Ubuntu 18.04
sudo gedit /etc/php/7.2/mods-available/mailcatcher.ini

# Ubuntu 16.04
sudo gedit /etc/php/7.0/mods-available/mailcatcher.ini
```

```INI
;sendmail_path = /usr/bin/env /usr/local/bin/catchmail -t -f 'www-data@localhost'
sendmail_path = /usr/sbin/sendmailfake
```

### Finish

```Shell
sudo reboot
```

## Documentation - What can i do?

### Passwörter
Die Passwörter der Linux Benutzer heißen genauso wie die Benutzernamen.

* Benutzer: root | Passwort: root
* Benutzer: user | Passwort: user

Der MySQL Zugang:
* Benutzer: root | Passwort: root

### SSHFS share - Linux configuration

Connect over SSH from Linux host to Linux guest.
IP address must be adapted for the virtual machine.

Run in a terminal window:

```Shell
sudo apt install sshfs
sudo mkdir -p /mnt/ssh/vm

gedit ~/.bashrc && gedit ~/.zshrc
```

Append to file ~/.bashrc and ~/.zshrc:

```Shell
alias vm-on='sshfs -o IdentitiesOnly=yes -o compression=no -o cache=yes -o kernel_cache -o allow_other -o IdentityFile=~/.ssh/id_rsa -o idmap=user -o uid=1000 -o gid=1000 user@123.123.123.123:/mnt/data/var/www /mnt/ssh/vm'

alias vm-off='fusermount -u /mnt/ssh/vm'
```

### Samba/Windows share

Connect over Samba from Windows/Linux host to Linux guest.
The folder /var/www is accessible over Samba share "www".
IP address (123.123.123.123) must be adapted for the virtual machine.

#### Samba/Windows share - Windows configuration

Run in a command window:

```Shell
net use Z: \\123.123.123.123\www /PERSISTENT:YES
```

#### Samba/Windows share - Linux configuration

Run in a terminal window:

```Shell
sudo apt install cifs-utils
sudo mkdir -p /mnt/samba/vm
sudo chmod 777 /mnt/samba/vm

sudo /etc/fstab
```

Append to file /etc/fstab with your virtual machine IP:

```Text
//123.123.123.123/www /mnt/samba/vm cifs uid=localUsername,username=user,password=user 0 0
```

### Switch PHP Version

```Shell
# List installed PHP versions
phpbrew list

# Switch PHP version permanent
phpbrew switch php-7.2.3

# Switch PHP version temporary only for current enviroment in terminal
phpbrew use php-7.2.3

# Show current PHP version
php -v
```

### DNS Server (example.vm)

You can use DNS Server for the example.vm domains to work.
IP address (123.123.123.123) must be adapted for the virtual machine.

#### Linux DNS Server

```Shell
# sudo apt install resolvconf
sudo gedit /etc/NetworkManager/NetworkManager.conf
```

Append to file: /etc/NetworkManager/NetworkManager.conf

```ini
[main]
dns=dnsmasq
```

```Shell
sudo sh -c 'echo "nameserver 127.0.1.1" >> /etc/resolvconf/resolv.conf.d/head'
sudo sh -c 'echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/head'
sudo sh -c 'echo "address=/.vm/123.123.123.123" >> /etc/NetworkManager/dnsmasq.d/development'
sudo systemctl restart network-manager
sudo resolvconf -u
```

#### Windows DNS Server (Acrylic DNS Proxy)

Download and install: http://mayakron.altervista.org/wikibase/show.php?id=AcrylicHome

Open Systemsteuerung > Netzwerk und Internet > Netzwerkverbindungen

Edit network > Internetprotocol, Version 4 (TCP/IPv4) > Folgende DNS-Serveradressen verwenden
* Bevorzugter DNS-Server: 127.0.0.1

Startmenü > Acrylic DNS Proxy > Edit Acrylic Hosts File

Append with your virtual machine IP:

```Text
123.123.123.123 /.*\.vm$
```

Startmenü > Acrylic DNS Proxy
* Stop Acrylic Service
* Start Acrylic Service

### E-Mail - MailCachter
Wird der MailCachter verwendet. Können E-Mails zu dieser SMTP Adresse versendet werden:

```Text
smtp://127.0.0.1:1025
```

Um zu sehen, ob eine E-Mail versendet wurde, kann man auf diese Webseite gehen.
IP-Adresse muss außerhalb der virtuellen Maschine angepasst werden.

```Text
http://127.0.0.1:1080/
```

### Apache & Nginx
Alle Seiten welche normal aufgerufen werden, also über die Ports 80 & 443, gehen auf den Nginx.
Für den Apache gibt es die Ports 8080 & 4430.

Über einen apache-proxy (siehe config) im Nginx, kann man den Verkehr durchleiten zum Apache,
falls es über die Standardports 80 & 443 gehen soll.

In der Regel wird pro Domain eine Konfiguration angelegt.
Beispiel Dateien sind nginx-demo oder apache-demo.

### Apache & Nginx - Wildcard Domain
Für verrückte oder faule gibt es die Möglichkeit Wildcard Domains zu verwenden.
Der Nachteil ist, dass die PHP Version für alle Domains gleich ist.
In den Dateien zzz-wildcard-* kann man das konfigurieren.

* Wildcard für Lokale Domains

```Text
*.*.*.dev.vm -> www.example.org.dev.vm -> /var/www/example.org/www/public
*.*.dev.vm -> example.org.dev.vm -> /var/www/example.org/public

*.*.vm -> www.example.vm -> /var/www/example/www/public
*.vm -> example.vm -> /var/www/example/public
```

* Wildcard für externe Domains

```Text
*.*.*.dev.vm00.example.org -> www.example.org.dev.vm00.example.org -> /var/www/example.org/www/public
*.*.dev.vm00.example.org -> example.org.dev.vm00.example.org -> /var/www/example.org/public

*.*.vm00.example.org -> www.example.vm00.example.org -> /var/www/example/www/public
*.vm00.example.org -> example.vm00.example.org -> /var/www/example/public
```

### PHP extension xDebug & IDE (PhpStorm)
PhpStorm > Run > Start Listening for PHP Debug Connections

@todo
PhpStorm reagiert automatisch, wenn die Seite neu geladen wird.
Der Server muss dann zu PhpStorm hinzugefügt werden.

Macht das hier überflüssig: xdebug.remote_host=192.168.56.1
Würde sowieso wegen anderer Einstellung nicht funktionieren.

@deprecated
PhpStorm > Run > Edit Configurations > Defaults > PHP Remote Debug
PhpStorm > Run > Edit Configurations > (+) Add > PHP Remote Debug
- Filter debug connection by IDE key: true
- Server (anlegen) > 127.0.0.1:9001 - /var/www/example (IP & Port so lassen!)
- IDE key (Session ID): PHPSTORM

## Troubleshooting

### MySQL not working

Set host "localhost" to "127.0.0.1".
