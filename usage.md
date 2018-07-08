## Virtualbox import

Import the virtual machine and add a new hard disk.

The second hard disk is for your MySQL and Website data.
This allows you to variably adjust the storage space and even move it to another hard drive in the host system.

* Expert mode
* Virtualbox > File > Import Appliance

VirtualBox > Settings

* General
  - Advanced > Snapshot Folder: (Maybe move to other folder)
* System
  - Motherboard > Memory: 2048 or 4096 MB
  - Processor > CPU: 4 (Maximum of green)
* Storage
  - Create new hard disk > Expert mode
    - File location: Data (Should be on your biggest drive)
    - File size: 1TB (Maximum of available space)
    - Hard disk file type: VMDK
    - Storage on physical hard disk: Dynamically allocated
    - Sata Port 1
* Network
  - Configure Adapter 1
  - Configure Adapter 2
  - Configure Adapter 3
    - Enable Network Adapter = True
    - Attached to: Host-only Adapter
    - Name: (Virtualbox)
    - Adapter Type: Intel PRO/1000 MT Desktop (82540EM)
    - Promiscuous Mode: Allow All

Optional: Install Virtualbox Extension Pack

## Optional: Change keyboard layout

Example:
* Generic 105-key keyboard
* English (US)

```Shell
sudo dpkg-reconfigure keyboard-configuration
```

## HDD2 - Format second hard disk

Format the second hard disk.

### HDD2 - Format second hard disk (Terminal - recommended)

Format the second hard disk by using a terminal.

* Start menu > Terminal

```Shell
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo fdisk /dev/sdb ${TGTDEV}
  g # create a new empty GPT partition table
  n # new partition
  1 # partition number 1
    # first sector (default)
    # last sector (default)
  p # print the partition table
  w # write table to disk and exit
EOF

sudo mkfs.ext4 /dev/sdb1
```

### HDD2 - Format second hard disk (GParted - alternative)

Format the second hard disk by using GParted (GUI).

For a server you need a Ubuntu Desktop Live CD.

* Start menu > GParted
* Select device (/dev/sdb)
* Device > Create Partition Table > msdos or gpt
* Partition > New
    - File system: ext4
    - Label: Data

Reboot if you use a live disk.

## HDD2 - Mount second hard disk (Fstab)

* Start menu > Terminal

```Shell
sudo mkdir /mnt/data
sudo blkid | grep sdb

sudo vim /etc/fstab
```

* Ubuntu 18.04: Append to fstab

```Text
UUID=288132af-be1e-4a3a-a2b6-1210c9816f50 /mnt/data ext4 defaults 0 0
```

* Other Ubuntu: Append to fstab

```Text
UUID=288132af-be1e-4a3a-a2b6-1210c9816f50 /mnt/data ext4 errors=remount-ro 0 1
```

* Execute in Terminal

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

sudo vim /etc/apparmor.d/tunables/alias
```

Append to file alias.

```Text
alias /var/lib/mysql/ -> /mnt/data/var/lib/mysql/,
```

Restart AppArmor and MySQL.

```Shell
sudo service apparmor restart
sudo service mysql start
```

## Virtualbox import - Konfigurieren

### Generate SSH Key

Use your own e-mail address.

```Shell
ssh-keygen -t rsa -b 4096 -C 'user@example.org'
```

### Convert SSH Key to Putty Key

Can be accessed via Windows Share, for example for Putty or HeidiSQL.


```Shell
puttygen /home/user/.ssh/id_rsa -o /var/www/id_rsa.ppk
```

### Git konfigurieren

Enter your own name & e-mail.

```Shell
git config --global user.name 'Your Name'
git config --global user.email 'user@example.org'
```

### Development Context (User & Root)

Search for "Development/YourName" and replace it in your own name.

```Shell
sudo vim /etc/apache2/conf-available/macro-virtual-host-defaults.conf
sudo vim /etc/nginx/snippets/fastcgi-php.conf
```

## Add enviroment variables

Replace "Development/YourName" with your own name.

```Shell
sudo sh -c 'echo "TYPO3_CONTEXT=Development/YourName" >> /etc/environment'
sudo sh -c 'echo "FLOW_CONTEXT=Development/YourName" >> /etc/environment'
sudo sh -c 'echo "WWW_CONTEXT=Development/YourName" >> /etc/environment'
```

### Optional: Set domain

Search for "vm00.example.org" and replace it in your domain.

```Shell
find /etc/apache2/sites-available /etc/nginx/sites-available -type f -exec sed -i '' \
    -e 's/vm00\.example\.org/vm00\.company\.de/g' \
    -e 's/vm00\\\.example\\\.org/vm00\\\.company\\\.de/g' \
    {} \;

sudo apache2ctl configtest && sudo systemctl restart apache2
sudo nginx -t && sudo systemctl restart nginx
```

### Set hostname

Search for "dev-vm" and replace it in your name.

Allowed: a-z 0-9 - (Hyphen)

Omit capitalization! For example: dev-your-name

```Shell
sudo vim /etc/hostname
sudo vim /etc/hosts
sudo vim /etc/apache2/conf-available/server-name.conf
```

### Optional Ubuntu 18.04 Server: Set static IP in network configuration

Edit Netplan file.

```Shell
ls /etc/netplan
sudo vim /etc/netplan/50-cloud-init.yaml
```

Change enp0s8 in 50-cloud-init.yaml.

```yaml
network:
    ethernets:
        enp0s8:
            addresses: [192.168.178.50/24]
            gateway4: 192.168.178.1
            nameservers:
                addresses: [127.0.1.1, 8.8.8.8]
```

Restart network.

```Shell
sudo netplan generate && sudo netplan apply
```

### Optional Other Ubuntu: Set static IP in network configuration

Get and configure interfaces.

```Shell
ip a
sudo vim /etc/network/interfaces
```

Adapt file interfaces.

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

Reconnect network card, restart in case of doubt.

```Shell
sudo ifdown -a && sudo ifup -a
```

### Optional Ubuntu Desktop: Install Software

 * https://atom.io/

```Shell
sudo apt -y install terminator
```

### Optional: Change login shell permanently

Change from "bash" to "zsh" for the current user.

```Shell
chsh -s $(which zsh)
# chsh -s $(which bash)
```

### Optional: Switch from MailCachter to Fakemail

Not recommended, but possible.

```Shell
vim /home/user/.phpbrew/php/php-7.2.5/etc/php.ini
vim /home/user/.phpbrew/php/php-7.1.17/etc/php.ini
vim /home/user/.phpbrew/php/php-7.0.30/etc/php.ini
vim /home/user/.phpbrew/php/php-5.6.36/etc/php.ini
vim /home/user/.phpbrew/php/php-5.5.38/etc/php.ini
vim /home/user/.phpbrew/php/php-5.4.45/etc/php.ini

# Ubuntu 18.04
sudo vim /etc/php/7.2/mods-available/mailcatcher.ini

# Ubuntu 16.04
sudo vim /etc/php/7.0/mods-available/mailcatcher.ini
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

The passwords of Linux users are the same as the user names.

* Username: root | Password: root
* Username: user | Password: user

The MySQL access:

* Username: root | Password: root

### SSHFS share - Linux configuration

Connect over SSH from Linux host to Linux guest.
IP address must be adapted for the virtual machine.

Run in a terminal window:

```Shell
sudo apt install sshfs
sudo mkdir -p /mnt/ssh/vm

vim ~/.bashrc && vim ~/.zshrc
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

#### DNS Server - Linux Ubuntu Desktop

```Shell
# sudo apt install resolvconf
sudo vim /etc/NetworkManager/NetworkManager.conf
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

Start menu > Acrylic DNS Proxy > Edit Acrylic Hosts File

Append with your virtual machine IP:

```Text
123.123.123.123 /.*\.vm$
```

Start menu > Acrylic DNS Proxy

* Stop Acrylic Service
* Start Acrylic Service

### E-Mail - MailCachter

If the MailCachter is used, e-mails can be sent to this SMTP address:

```Text
smtp://127.0.0.1:1025
```

To see if an e-mail has been sent, you can go to this website.
IP address must be adjusted outside the virtual machine.

```Text
http://127.0.0.1:1080/
```

### Apache & Nginx

All pages which are called normally, ie via the ports 80 & 443, go to the nginx.
Apache has ports 8080 & 4430.

Via an apache-proxy (see config) in nginx, one can pass the traffic to Apache,
if it should go over the standard ports 80 & 443.

As a rule, a configuration is created per domain.
Example files are nginx-demo or apache-demo.

### Apache & Nginx - Wildcard domain

For crazy or lazy there is the possibility to use wildcard domains.
The downside is that the PHP version is the same for all domains.
In zzz-wildcard-* you can configure this.

Wildcard for local domains:

```Text
*.*.*.dev.vm -> www.example.org.dev.vm -> /var/www/example.org/www/public
*.*.dev.vm -> example.org.dev.vm -> /var/www/example.org/public

*.*.vm -> www.example.vm -> /var/www/example/www/public
*.vm -> example.vm -> /var/www/example/public
```

* Wildcard for extern domains:

```Text
*.*.*.dev.vm00.example.org -> www.example.org.dev.vm00.example.org -> /var/www/example.org/www/public
*.*.dev.vm00.example.org -> example.org.dev.vm00.example.org -> /var/www/example.org/public

*.*.vm00.example.org -> www.example.vm00.example.org -> /var/www/example/www/public
*.vm00.example.org -> example.vm00.example.org -> /var/www/example/public
```

### PHP extension xDebug & IDE (PhpStorm)

To activate or disable xDebug run in console:

```Shell
xdebug
```

#### Configure xDebug in PhpStorm

Go to the menu:

PhpStorm > Run > Start Listening for PHP Debug Connections

then reload website.
PhpStorm should responds automatically and ask if your want to add a server.

##### Configure xDebug in PhpStorm - Add Server and path mapping

For some projects you must add a server and a path mapping.

PhpStorm > Run > Edit Configurations > (+) Add > PHP Remote Debug
- Filter debug connection by IDE key: true
- Add a Server (...) - Example: Nginx https
  - Name: www.example.vm:443
  - Host: www.example.vm
  - Port: 443
  - Use path mappings = true
  - Project files/mnt/vm/example/www = /mnt/data/var/www/example/www (Connection between host and guest system)
- Add a Server (...) - Example: Apache https
  - Name: www.example.vm:4430
  - Host: www.example.vm
  - Port: 4430
  - Use path mappings = true
  - Project files/mnt/vm/example/www = /mnt/data/var/www/example/www (Connection between host and guest system)
- IDE key (Session ID): PHPSTORM

@todo
Make this unnecessary: xdebug.remote_host=192.168.56.1
Would not work anyway because of other settings.

@deprecated Maybe not. Works with symfony
PhpStorm > Run > Edit Configurations > Defaults > PHP Remote Debug
- Name: example_www (Just a name)

## Troubleshooting

### MySQL not working

Set host "localhost" to "127.0.0.1".
