## VirtualBox - Create a new virtual machine

* Install VirtualBox: https://virtualbox.org/

VirtalBox > New > (Expert Mode)

* Name: UbuntuDev
* Type: Linux
* Version: Ubuntu (64 bit)
* Memory size: 4096 MB
* Hard disk: No - Do not add a virtual hard disk

VirtualBox > Settings

* General > Advanced
  - Shared Clipboard: Bidirectional (optional)
  - Drag'n'Drop: Bidirectional (optional)
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

## Choose Ubuntu Desktop or Server

Desktop and servers both have their advantages and disadvantages.
The desktop has a user interface that is easy for newbies.
The server consumes less disk space, memory and so on.
Choose your version wisely.

* Download Ubuntu: https://ubuntu.com/

### Install Ubuntu Desktop (16.04 or 18.04)

Note: Ubuntu 18.04, has no PHP 5.* and docker ready.

* For Ubuntu 18.04: Full installation

* Your name: user
* Computer name: dev-vm
* Username: user
* Passwort: user
* Log in automatically = true

* System Settings > Display Resolution: 1280x800
* Icons: Nautilus, Firefox, Terminal


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
* Page 2: (Your preference)
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

Enable repository, update system and install software.

```Shell
sudo add-apt-repository multiverse
sudo apt update
sudo apt -y dist-upgrade

sudo apt -y install openssh-server \
  curl gparted git htop meld nautilus-compare \
  putty-tools vim whois net-tools resolvconf
```

Configure prefered editor (vim.basic).

```Shell
sudo update-alternatives --config editor
```

Optional: Add german language pack.

```Shell
sudo apt-get install language-pack-de
```

### Visudo: No password for user

```Shell
sudo visudo
```

Append in file visudo:

```text
user ALL=(ALL) NOPASSWD: ALL
```

### Ubuntu Desktop: VirtualBox Group

Set VirtualBox group to user.

```Shell
sudo usermod -aG vboxsf ${USER}
sudo reboot
```

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

# Network 1
auto enp0s3
iface enp0s3 inet dhcp

# Network 2
auto enp0s8
iface enp0s8 inet dhcp
```

Restart network interfaces.

```Shell
sudo ifdown -a && sudo ifup -a
```

### Repository

Clone Reository.

```Shell
git clone https://github.com/Cyb10101/dev-vm-linux.git /home/user/dev-vm-linux
```

#### Copy files

```Shell
cp /home/user/dev-vm-linux/usr/local/bin/xdebug /usr/local/bin/
```

#### Ubuntu Desktop

```Shell
rsync -av /home/user/dev-vm-linux/home/user/ /home/user/
```

#### Ubuntu Server

```Shell
rsync -av /home/user/dev-vm-linux/home/user/.* /home/user/
```

## Ubuntu Desktop: Configure Grub

```Shell
sudo vim /etc/default/grub
```

Remove "quiet splash" add "" in grub file.

```INI
GRUB_CMDLINE_LINUX_DEFAULT="consoleblank=0"
```

Update Grub and write new entries.

```Shell
sudo update-grub
```

### Optional: Pretest PhpBrew Versions and update PHP

In the script update the PHP versions for the installation.

* Create Snapshot, install PHP, install PhpBrew
* Query and update available PHP versions
* Reset snapshot

```Shell
sudo apt -y install php

# Install PhpBrew

# PHP Versionen aktualisieren
find . -type f -exec sed -i '' \
    -e 's/7\.2\.3/7\.2\.5/g' \
    -e 's/7\.1\.15/7\.1\.17/g' \
    -e 's/7\.0\.29/7\.0\.30/g' \
    -e 's/5\.6\.34/5\.6\.36/g' \
    {} \;

mv etc/nginx/snippets/php-7.2.3.conf etc/nginx/snippets/php-7.2.5.conf
mv etc/nginx/snippets/php-7.1.15.conf etc/nginx/snippets/php-7.1.17.conf
mv etc/nginx/snippets/php-7.0.29.conf etc/nginx/snippets/php-7.0.30.conf
mv etc/nginx/snippets/php-5.6.34.conf etc/nginx/snippets/php-5.6.36.conf
```

## Ubuntu Desktop: Configure operating system

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
```Shell
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
```

### Ubuntu 16.04 Desktop
```Shell
gsettings set org.gnome.desktop.interface menus-have-icons true
gsettings set org.gnome.desktop.interface buttons-have-icons true
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set com.canonical.indicator.session show-real-name-on-panel true
gsettings set com.canonical.Unity integrated-menus true
```

* Ubuntu 16.04 Desktop: System Settings > Security & Privacy > Files & Applications > Record file and application usage = Off

### Optional: Watcher for changes to the configuration

For further configuration, you can use these tools.

```Shell
dconf watch /
sudo apt -y install dconf-editor
gsettings list-recursively | grep search
```

## Configure Bash (User & Root)

```Shell
sudo cp /home/user/dev-vm-linux/home/user/.shell-methods /root/
vim ~/.bashrc && sudo vim /root/.bashrc
```

* Zur .bashrc hinzufügen

```Shell
source ~/.shell-methods
#sshAgentRestart
#sshAgentAddKey 24h ~/.ssh/id_rsa
addAlias
stylePS1
#terminalMotd
```

## Configure Zsh (User & Root)

```Shell
sudo apt -y install zsh
sudo rsync -av /home/user/dev-vm-linux/home/user/.zshrc /root/
sudo rsync -av /home/user/dev-vm-linux/home/user/.oh-my-zsh/ /root/.oh-my-zsh/
git clone https://github.com/robbyrussell/oh-my-zsh.git /tmp/.oh-my-zsh

rsync -av /tmp/.oh-my-zsh/ ~/.oh-my-zsh/
sudo rsync -av /tmp/.oh-my-zsh/ /root/.oh-my-zsh/
sudo chown -R root:root /root/.oh-my-zsh
sudo chown root:root /root/.zshrc
```

## Message of the day

### Optional: Disable to much information

```Shell
sudo chmod -x /etc/update-motd.d/10-help-text

# Ubuntu 16.04:
sudo chmod -x /etc/update-motd.d/91-release-upgrade
```

### Optional: Keep me from working

Yes, you wan't it! Your boss would kill you, but your soul thanks you.
Each new Terminal you opening on desktop or with ssh, you get a new message.

Install required packages:

```Shell
sudo apt install boxes lolcat fortune-mod fortunes fortunes-min fortunes-de fortunes-ubuntu-server fortunes-bofh-excuses

sudo chmod -x /etc/update-motd.d/60-ubuntu-server-tip
```

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

## DNS Server (example.vm)

Add own machine to hosts file.

```Shell
sudo vim /etc/hosts
```

Edit or append to hosts file.

```Shell
127.0.1.1    dev-vm
```

Install Dnsmasq and configure resolv.conf.

```Shell
sudo apt -y install dnsmasq
sudo sh -c 'echo "nameserver 127.0.1.1" >> /etc/resolvconf/resolv.conf.d/head'
sudo sh -c 'echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/head'
```

### Ubuntu Desktop

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

### Ubuntu 16.04 Server

Configure Dnsmasq.

```Shell
sudo sh -c 'echo "address=/.vm/127.0.0.1" >> /etc/dnsmasq.conf'

sudo service dnsmasq restart
sudo resolvconf -u
```

### Ubuntu 18.04 Server

Configure Dnsmasq.

```Shell
sudo sh -c 'echo "address=/.vm/127.0.0.1" >> /etc/dnsmasq.conf'
```

Edit Netplan file.

```Shell
ls /etc/netplan
sudo vim /etc/netplan/50-cloud-init.yaml
```

Edit 50-cloud-init.yaml.

```yaml
network:
    version: 2
    ethernets:
        enp0s3:
            addresses: []
            dhcp4: true
            optional: true
            nameservers:
                addresses: [127.0.1.1, 8.8.8.8]
        enp0s8:
            addresses: []
            dhcp4: true
            optional: true
            nameservers:
                addresses: [127.0.1.1, 8.8.8.8]
```

Configure Dnsmasq and restart network.

```Shell
sudo service dnsmasq restart
sudo netplan generate && sudo netplan apply
sudo resolvconf -u
```

### All Ubuntu: DNS Server Status

```Shell
cat /etc/resolv.conf
ping example.vm

systemd-resolve --status
```

## System Webserver (Apache)

```Shell
sudo apt -y install apache2 php libapache2-mod-php php-fpm

# Ubuntu 18.04
sudo a2enconf php7.2-fpm

# Ubuntu 16.04
sudo a2enconf php7.0-fpm

# Both Ubuntu...
sudo a2enmod actions alias deflate expires headers macro rewrite proxy proxy_fcgi ssl vhost_alias

sudo apt -y install imagemagick graphicsmagick
# sudo apt -y install graphicsmagick graphicsmagick-imagemagick-compat

sudo rsync -av /home/user/dev-vm-linux/etc/apache2/conf-available/ /etc/apache2/conf-available/
sudo rsync -av /home/user/dev-vm-linux/etc/apache2/sites-available/ /etc/apache2/sites-available/
sudo cp /home/user/dev-vm-linux/etc/apache2/ports.conf /etc/apache2/
sudo chown -R user:user /etc/apache2/sites-available
sudo chown -R user:user /etc/apache2/sites-enabled
sudo usermod -aG adm ${USER}

sudo chmod 0775 /var/www
sudo chown -R user:user /var/www
sudo find /var/www -type d -exec chmod 775 {} \;
sudo find /var/www -type f -exec chmod 664 {} \;
sudo find /var/www -type d -exec chmod g+s {} \;

sudo vim /etc/apache2/envvars
```

Configure file envvars.

```Text
export APACHE_RUN_USER=user
export APACHE_RUN_GROUP=user
```

Enable configuration and websites.

```Shell
sudo a2enconf macro-fancy-indexing.conf
sudo a2enconf macro-virtual-host-defaults.conf
sudo a2enconf macro-virtual-host-ssl.conf
sudo a2enconf phpbrew.conf
sudo a2enconf server-name.conf
sudo a2ensite apache-demo.conf
sudo a2ensite zzz-wildcard-vm.conf
sudo a2ensite zzz-wildcard-company.conf
sudo apache2ctl configtest && sudo systemctl restart apache2
```

## Nginx

```Shell
sudo apt -y install nginx nginx-extras
sudo rsync -av /home/user/dev-vm-linux/etc/nginx/sites-available/ /etc/nginx/sites-available/
sudo rsync -av /home/user/dev-vm-linux/etc/nginx/snippets/ /etc/nginx/snippets/
sudo chown -R user:user /etc/nginx/sites-available
sudo chown -R user:user /etc/nginx/sites-enabled
sudo chown -R user:user /etc/nginx/snippets

sudo vim /etc/nginx/nginx.conf
```

* Datei nginx.conf anpassen

```Text
user user;
http {
	index index.php index.html index.htm;
	server_names_hash_bucket_size 512;
	client_max_body_size 200M;

	proxy_connect_timeout 600;
	proxy_send_timeout    600;
	proxy_read_timeout    600;
	send_timeout          600;
}
```

```Shell
sudo vim /etc/nginx/snippets/fastcgi-php.conf
```

* Datei fastcgi-php.conf am ende hinzufügen

```Text
fastcgi_param TYPO3_CONTEXT Development/YourName;
fastcgi_param FLOW_CONTEXT Development/YourName;
fastcgi_param WWW_CONTEXT Development/YourName;
fastcgi_param SERVER_NAME $host;
```

```Shell
sudo ln -s /etc/nginx/sites-available/apache-proxy /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/nginx-demo /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/zzz-wildcard /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx
```

## PhpBrew

* http://phpbrew.github.io/phpbrew/
* https://github.com/phpbrew/phpbrew/wiki/Requirement

```Shell
curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew
chmod +x phpbrew
sudo mv phpbrew /usr/local/bin/phpbrew
phpbrew init
phpbrew update
phpbrew known
```

### PhpBrew - Add configuration to bash or zsh
```Shell
vim ~/.bashrc && vim ~/.zshrc
```

Append on end to files .bashrc & .zshrc

```Shell
source /home/user/.phpbrew/bashrc
```

Reboot operating system.

### PhpBrew - Requirements

```Shell
sudo chmod -R oga+rw /usr/lib/apache2/modules
sudo chmod -R oga+rw /etc/apache2

sudo apt -y install autoconf apache2-dev libxml2-dev libcurl4-openssl-dev pkg-config libssl-dev libbz2-dev libjpeg-turbo8-dev libpng-dev libxpm-dev libfreetype6-dev libmcrypt4 libmcrypt-dev libpq-dev libreadline-dev libtidy-dev libxslt1-dev
```

### PhpBrew - Install PHP 7.2.5

```Shell
phpbrew install -j $(nproc) php-7.2.5 \
    +apxs2 +bcmath +bz2 +calendar +cli +ctype +curl +dom \
    +fileinfo +filter +fpm +ftp +gd +gettext +iconv +intl +ipc +json +ldap \
    +mbregex +mbstring +mhash +mcrypt +mysql +opcache +openssl \
    +pcntl +pcre +pdo +pear +pgsql +phar +posix +readline +session +soap +sockets +sqlite +tidy +tokenizer +xml +zip \
    -- \
    --enable-gd-native-ttf \
    --with-gd=shared \
    --with-freetype-dir=/usr/include/freetype2/freetype \
    --with-jpeg-dir=/usr \
    --with-libdir=lib/x86_64-linux-gnu \
    --with-png-dir=/usr \
    --with-vpx-dir=/usr \
    --with-xpm-dir=/usr
```

* On build error 'a2enmod php7' retry once

```Shell
phpbrew use php-7.2.5

phpbrew extension install gd -- \
    --enable-gd-native-ttf \
    --with-gd=shared \
    --with-freetype-dir=/usr/include/freetype2/freetype \
    --with-jpeg-dir=/usr \
    --with-libdir=lib/x86_64-linux-gnu \
    --with-png-dir=/usr \
    --with-vpx-dir=/usr \
    --with-xpm-dir=/usr

phpbrew extension install opcache
phpbrew extension install apcu
phpbrew ext install xdebug 2.6.0
```

### PhpBrew - Install PHP 7.1.17

```Shell
phpbrew install -j $(nproc) php-7.1.17 \
    +apxs2 +bcmath +bz2 +calendar +cli +ctype +curl +dom \
    +fileinfo +filter +fpm +ftp +gd +gettext +iconv +intl +ipc +json +ldap \
    +mbregex +mbstring +mhash +mcrypt +mysql +opcache +openssl \
    +pcntl +pcre +pdo +pear +pgsql +phar +posix +readline +session +soap +sockets +sqlite +tidy +tokenizer +xml +zip \
    -- \
    --enable-gd-native-ttf \
    --with-gd=shared \
    --with-freetype-dir=/usr/include/freetype2/freetype \
    --with-jpeg-dir=/usr \
    --with-libdir=lib/x86_64-linux-gnu \
    --with-png-dir=/usr \
    --with-vpx-dir=/usr \
    --with-xpm-dir=/usr

phpbrew use php-7.1.17

phpbrew ext install gd -- \
	--enable-gd-native-ttf \
	--with-gd=shared \
	--with-freetype-dir=/usr/include/freetype2/freetype \
	--with-jpeg-dir=/usr \
	--with-libdir=lib/x86_64-linux-gnu \
	--with-png-dir=/usr \
	--with-vpx-dir=/usr \
	--with-xpm-dir=/usr

phpbrew ext install opcache
phpbrew ext install apcu
phpbrew ext install xdebug 2.6.0
```

### PhpBrew - Install PHP 7.0.30

```Shell
phpbrew install -j $(nproc) php-7.0.30 \
    +apxs2 +bcmath +bz2 +calendar +cli +ctype +curl +dom \
    +fileinfo +filter +fpm +ftp +gd +gettext +iconv +intl +ipc +json +ldap \
    +mbregex +mbstring +mhash +mcrypt +mysql +opcache +openssl \
    +pcntl +pcre +pdo +pear +pgsql +phar +posix +readline +session +soap +sockets +sqlite +tidy +tokenizer +xml +zip \
    -- \
    --enable-gd-native-ttf \
    --with-gd=shared \
    --with-freetype-dir=/usr/include/freetype2/freetype \
    --with-jpeg-dir=/usr \
    --with-libdir=lib/x86_64-linux-gnu \
    --with-png-dir=/usr \
    --with-vpx-dir=/usr \
    --with-xpm-dir=/usr

phpbrew use php-7.0.30

phpbrew ext install gd -- \
	--enable-gd-native-ttf \
	--with-gd=shared \
	--with-freetype-dir=/usr/include/freetype2/freetype \
	--with-jpeg-dir=/usr \
	--with-libdir=lib/x86_64-linux-gnu \
	--with-png-dir=/usr \
	--with-vpx-dir=/usr \
	--with-xpm-dir=/usr

phpbrew ext install opcache
phpbrew ext install apcu
phpbrew ext install xdebug 2.6.0
```

### Ubuntu 16.04: PhpBrew - Install PHP 5.6.36

```Shell
sudo apt -y install libvpx-dev

phpbrew install -j $(nproc) php-5.6.36 \
    +apxs2 +bcmath +bz2 +calendar +cli +ctype +curl +dom \
    +fileinfo +filter +fpm +ftp +gd +gettext +iconv +intl +ipc +json +ldap \
    +mbregex +mbstring +mhash +mcrypt +mysql +opcache +openssl \
    +pcntl +pcre +pdo +pear +pgsql +phar +posix +readline +session +soap +sockets +sqlite +tidy +tokenizer +xml +zip \
    -- \
    --enable-gd-native-ttf \
    --with-gd=shared \
    --with-freetype-dir=/usr/include/freetype2/freetype \
    --with-jpeg-dir=/usr \
    --with-libdir=lib/x86_64-linux-gnu \
    --with-png-dir=/usr \
    --with-vpx-dir=/usr \
    --with-xpm-dir=/usr
```

* On build error 'a2enmod php5' retry once

```Shell
phpbrew use php-5.6.36

phpbrew ext install gd -- \
	--enable-gd-native-ttf \
	--with-gd=shared \
	--with-freetype-dir=/usr/include/freetype2/freetype \
	--with-jpeg-dir=/usr \
	--with-libdir=lib/x86_64-linux-gnu \
	--with-png-dir=/usr \
	--with-vpx-dir=/usr \
	--with-xpm-dir=/usr

phpbrew ext install opcache
phpbrew ext install xdebug 2.5.5
```

### Ubuntu 16.04: PhpBrew - Install PHP 5.5.38

```Shell
phpbrew install -j $(nproc) php-5.5.38 \
    +apxs2 +bcmath +bz2 +calendar +cli +ctype +curl +dom \
    +fileinfo +filter +fpm +ftp +gd +gettext +iconv +intl +ipc +json +ldap \
    +mbregex +mbstring +mhash +mcrypt +mysql +opcache +openssl \
    +pcntl +pcre +pdo +pear +pgsql +phar +posix +readline +session +soap +sockets +sqlite +tidy +tokenizer +xml +zip \
    -- \
    --enable-gd-native-ttf \
    --with-gd=shared \
    --with-freetype-dir=/usr/include/freetype2/freetype \
    --with-jpeg-dir=/usr \
    --with-libdir=lib/x86_64-linux-gnu \
    --with-png-dir=/usr \
    --with-vpx-dir=/usr \
    --with-xpm-dir=/usr

phpbrew use php-5.5.38

phpbrew ext install gd -- \
	--enable-gd-native-ttf \
	--with-gd=shared \
	--with-freetype-dir=/usr/include/freetype2/freetype \
	--with-jpeg-dir=/usr \
	--with-libdir=lib/x86_64-linux-gnu \
	--with-png-dir=/usr \
	--with-vpx-dir=/usr \
	--with-xpm-dir=/usr

phpbrew ext install opcache
phpbrew ext install xdebug 2.5.5
```

### Ubuntu 16.04: PhpBrew - Install PHP 5.4.45

```Shell
phpbrew install -j $(nproc) php-5.4.45 \
    +apxs2 +bcmath +bz2 +calendar +cli +ctype +curl +dom \
    +fileinfo +filter +fpm +ftp +gettext +iconv +intl +ipc +json +ldap \
    +mbregex +mbstring +mhash +mcrypt +mysql +opcache +openssl \
    +pcntl +pcre +pdo +pear +pgsql +phar +posix +readline +session +soap +sockets +sqlite +tidy +tokenizer +xml +zip \
    -- \
    --with-freetype-dir=/usr/include/freetype2/freetype \
    --with-jpeg-dir=/usr \
    --with-libdir=lib/x86_64-linux-gnu \
    --with-png-dir=/usr \
    --with-vpx-dir=/usr \
    --with-xpm-dir=/usr

phpbrew use php-5.4.45

phpbrew ext install gd -- \
	--enable-gd-native-ttf \
	--with-gd=shared \
	--with-freetype-dir=/usr/include/freetype2/freetype \
	--with-jpeg-dir=/usr \
	--with-libdir=lib/x86_64-linux-gnu \
	--with-png-dir=/usr \
	--with-xpm-dir=/usr

phpbrew ext install xdebug 2.4.1
```

### PhpBrew - Configure PHP

```Shell
phpbrew switch php-7.2.5

vim /home/user/.phpbrew/php/php-7.2.5/etc/php.ini
vim /home/user/.phpbrew/php/php-7.1.17/etc/php.ini
vim /home/user/.phpbrew/php/php-7.0.30/etc/php.ini
vim /home/user/.phpbrew/php/php-5.6.36/etc/php.ini
vim /home/user/.phpbrew/php/php-5.5.38/etc/php.ini
vim /home/user/.phpbrew/php/php-5.4.45/etc/php.ini
```

* PHP all

```INI
[PHP]
error_reporting = E_ALL
display_errors = On

max_execution_time = 300
max_input_time = 600
max_input_vars = 2000
memory_limit = 4096M

upload_max_filesize = 200M
post_max_size = 200M

[Date]
date.timezone = Europe/Berlin

[MySQLi]
mysqli.default_host = 127.0.0.1

[mail function]
sendmail_path = /usr/bin/env /usr/local/bin/catchmail -t -f 'www-data@localhost'
;sendmail_path = /usr/sbin/sendmailfake

[Session]
session.gc_maxlifetime = 86400
```

* PHP <= 5.6

```INI
[PHP]
always_populate_raw_post_data = -1

[MySQL]
mysql.default_host = 127.0.0.1
```

### PhpBrew - Configure PHP extension xDebug

```Shell
cp /home/user/dev-vm-linux/snippets/xdebug.ini /home/user/.phpbrew/php/php-7.2.5/var/db/
cp /home/user/dev-vm-linux/snippets/xdebug.ini /home/user/.phpbrew/php/php-7.1.17/var/db/
cp /home/user/dev-vm-linux/snippets/xdebug.ini /home/user/.phpbrew/php/php-7.0.30/var/db/
cp /home/user/dev-vm-linux/snippets/xdebug.ini /home/user/.phpbrew/php/php-5.6.36/var/db/
cp /home/user/dev-vm-linux/snippets/xdebug.ini /home/user/.phpbrew/php/php-5.5.38/var/db/
cp /home/user/dev-vm-linux/snippets/xdebug.ini /home/user/.phpbrew/php/php-5.4.45/var/db/

vim /home/user/.phpbrew/php/php-5.4.45/var/db/xdebug.ini
```

Change configuration for PHP 5.4.

```INI
zend_extension=/home/user/.phpbrew/php/php-5.4.45/lib/php/extensions/no-debug-non-zts-20100525/xdebug.so
```

Disable xDebug (Type: N).

```Shell
xdebug
```

### PhpBrew FPM configuration

```Shell
vim /home/user/.phpbrew/php/php-7.2.5/etc/php-fpm.d/www.conf
vim /home/user/.phpbrew/php/php-7.1.17/etc/php-fpm.d/www.conf
vim /home/user/.phpbrew/php/php-7.0.30/etc/php-fpm.d/www.conf
vim /home/user/.phpbrew/php/php-5.6.36/etc/php-fpm.conf
vim /home/user/.phpbrew/php/php-5.5.38/etc/php-fpm.conf
vim /home/user/.phpbrew/php/php-5.4.45/etc/php-fpm.conf
```

Comment user and group out:

```ini
;user = nobody
;group = nobody
```

### PhpBrew cleanups

Ubuntu 18.04: Find not used php versions and remove them.

```Shell
grep -linrE '5.6.36|5.5.38|5.4.45' /etc/apache2 /etc/nginx /home/user/.start-php-fpm.sh /usr/local/bin/xdebug
```

### PhpBrew autostart

```Shell
sudo vim /etc/crontab
```

Append on end in file crontab.

```Text
@reboot user /home/user/.start-php-fpm.sh
```

### PhpBrew Bugfix Apache

```Shell
sudo a2dismod php5
sudo a2dismod php7

# Ubuntu 18.04
sudo a2dismod php7.2

# Ubuntu 16.04
sudo a2dismod php7.0

sudo reboot
```

## MySQL

```Shell
sudo apt -y install mysql-server php-mysql
```

* Username & Password: root

### MySQL - Configuration

```Shell
sudo vim /etc/mysql/my.cnf
```

Append on end in file my.cnf:

```INI
[client]
user=root
password=root
default-character-set=utf8

[mysqld]
collation-server=utf8_unicode_ci
init-connect='SET NAMES utf8'
character-set-server=utf8
bind-address=127.0.0.1
sql_mode=""
#sql_mode="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"

[mysql]
default-character-set=utf8
pager=less -FSRX
```

Restart MySQL.

```Shell
sudo service mysql restart
```

###  MySQL - Allow access from normal users

```Shell
sudo mysql
```

* Run SQL code

```sql
SELECT host, user FROM mysql.user;
DROP USER 'root'@'%';
DROP USER 'root'@'localhost';
CREATE USER 'root'@'%' IDENTIFIED BY 'root';
CREATE USER 'root'@'localhost' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

## FakeMail

```Shell
sudo apt -y install tofrodos ack-grep
sudo cp /home/user/dev-vm-linux/usr/sbin/sendmailfake /usr/sbin/
```

## MailCachter

https://mailcatcher.me/

```Shell
sudo apt -y install build-essential libsqlite3-dev ruby-dev

sudo gem install mailcatcher

sudo vim /etc/crontab
```

Add at the end of the crontab file.

```Text
@reboot root $(which mailcatcher) --ip=0.0.0.0
```

### MailCachter - System PHP

```Shell
# Ubuntu 18.04
sudo vim /etc/php/7.2/mods-available/mailcatcher.ini

# Ubuntu 16.04
sudo vim /etc/php/7.0/mods-available/mailcatcher.ini
```

Append to file mailcatcher.ini:

```Text
sendmail_path = /usr/bin/env /usr/local/bin/catchmail -t -f 'www-data@localhost'
;sendmail_path = /usr/sbin/sendmailfake
```

Activate MailCachter.

```Shell
sudo phpenmod mailcatcher
```

Reboot operating system.

## Composer
https://getcomposer.org/download/

```Shell
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
sudo mv composer.phar /usr/local/bin/composer
```

## /var/www
https://packagist.org/packages/typo3/cms-base-distribution

```Shell
sudo rm -rf /var/www/html
sudo rsync -av /home/user/dev-vm-linux/var/www/ /var/www/

# PHP <= 7.2 - No LTS version - Long term support
# composer create-project typo3/cms-base-distribution /var/www/typo3demo ^9

# PHP <= 7.0
composer create-project typo3/cms-base-distribution /var/www/typo3demo ^8

php /var/www/typo3demo/vendor/bin/typo3cms install:setup \
    --no-interaction \
    --database-host-name=127.0.0.1 \
    --database-port=3306 \
    --database-user-name=root \
    --database-user-password=root \
    --database-name=typo3demo \
    --admin-user-name=admin \
    --admin-password=Admin123 \
    --site-setup-type=site
```

## Ubuntu Desktop: Firefox Browser
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

## Docker
https://docs.docker.com/install/linux/docker-ce/ubuntu/

```Shell
sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

* Ubuntu 18.04

```Shell
# Stable is in development, use edge
# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) edge"
```

* Ubuntu 16.04

```Shell
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

* Both Ubuntu

```Shell
sudo apt update
sudo apt -y install docker-ce
sudo usermod -aG docker ${USER}
sudo reboot
```

## Docker Compose
https://docs.docker.com/compose/install/#install-compose
https://github.com/docker/compose/releases

```Shell
sudo curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## Optional: Test Docker

```Shell
# Run hello world test
docker run hello-world

# Delete all container
docker rm $(docker ps -a -q)

# Delete all images
docker rmi $(docker images -q)
```

## Samba

```Shell
sudo apt -y install samba

sudo vim /etc/samba/smb.conf
```

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

```Shell
sudo smbpasswd -a user
# Password: user

sudo service smbd restart
```

## NPM - Node Package Manager

```Shell
cd /tmp && wget https://nodejs.org/dist/v8.11.0/node-v8.11.0-linux-x64.tar.xz
sudo tar xf node-v8.11.0-linux-x64.tar.xz
cd node-v8.11.0-linux-x64
sudo cp -r bin /
sudo cp -r include /
sudo cp -r lib /
sudo cp -r share /

# NPM Update
sudo npm install -g npm
```

### NPM - Install Packages

```Shell
sudo npm install -g bower grunt-cli
```

### Yarn - Package Manager

```Shell
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install --no-install-recommends yarn
```

## Ubuntu Desktop: HeidiSQL

* https://www.heidisql.com/
* https://www.chiark.greenend.org.uk/~sgtatham/putty/

```Shell
wget -O ~/Downloads/HeidiSQL.exe https://www.heidisql.com/installers/HeidiSQL_9.5.0.5196_Setup.exe
wget -O ~/Downloads/putty.msi https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.70-installer.msi

sudo apt -y install playonlinux
```

Open PlayOnLinux and create a new virtual drive.

* Tools > Manage Wine versions > Install latest 64 bit Wine version (current: 3.13)

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

```Shell
sudo vim /etc/acpi/powerbtn.sh
```

At the top of the file:

```Shell
/sbin/shutdown -h now 'Power button pressed' && exit 0
```

### Optional Ubuntu Desktop: Set Wallpaper

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

Example:

* Generic 105-key keyboard
* English (US)

```Shell
sudo dpkg-reconfigure keyboard-configuration
```

## Clean Apport crash

Send it or cancel with button "c":

```Shell
sudo apport-cli
```

## Updates

```Shell
sudo apt update && sudo apt -y dist-upgrade && sudo apt -y autoremove

sudo npm -g outdated
sudo npm install -g npm grunt-cli
```

## Cleanups

* Shared folders: remove

```Shell
sudo chown -R user:user /etc/apache2/sites-available
sudo chown -R user:user /etc/apache2/sites-enabled
sudo chown -R user:user /etc/nginx/sites-available
sudo chown -R user:user /etc/nginx/sites-enabled

rm -rf /home/user/dev-vm-linux

# Ubuntu 18.04
gio trash --empty

# Ubuntu 16.04
gvfs-trash --empty

# Both Ubuntu...
sudo /opt/VBoxGuestAdditions-*/uninstall.sh

sudo su
rm -rd /var/www/html
rm /home/user/.local/share/recently-used.xbel
rm /home/user/.mysql_history
rm /home/user/.bash_history
rm /home/user/.zsh_history
rm /root/.mysql_history
rm /root/.bash_history
rm /root/.zsh_history
poweroff
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
