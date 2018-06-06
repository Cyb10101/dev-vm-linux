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

## Install Ubuntu (16.04 or 18.04)

Note: Ubuntu 18.04, has no PHP 5.* and docker ready.

* Download Ubuntu: https://ubuntu.com/
* For Ubuntu 18.04: Full installation

* Your name: user
* Computer name: dev-vm
* Username: user
* Passwort: user
* Log in automatically = true

* System Settings > Display Resolution: 1280x800
* Icons: Nautilus, Firefox, Terminal

```Shell
sudo passwd root
```

* Root Passwort: root

### Clone repository

```Shell
sudo apt -y install git
git clone https://github.com/Cyb10101/dev-vm-linux.git /home/user/Desktop/dev-vm-linux
rsync -av /home/user/Desktop/dev-vm-linux/home/user/ /home/user/
```

### Configure System

```Shell
sudo add-apt-repository multiverse
sudo apt update
sudo apt -y dist-upgrade
sudo apt -y install curl gparted htop meld nautilus-compare openssh-server \
  putty-tools vim whois net-tools resolvconf

sudo update-alternatives --config editor
```

* Editor ändern, zum Beispiel auf vim.basic

```Shell
sudo visudo
```

* Datei visudo, am Ende hinzufügen

```text
user ALL=(ALL) NOPASSWD: ALL
```

```Shell
sudo usermod -aG vboxsf ${USER}
sudo reboot
```

## Grub konfigurieren

```Shell
sudo gedit /etc/default/grub
```

* Remove quiet splash

```INI
GRUB_CMDLINE_LINUX_DEFAULT=""
```

* Grub aktualisieren

```Shell
sudo update-grub
```

### Optional: Pretest PhpBrew Versions and update PHP
Im Script die PHP Versionen für die Installation aktualisieren.

* Snapshot erstellen, PHP installieren, PhpBrew installieren
* Verfügbare PHP Versionen abfragen und aktualisieren
* Snapshot zurücksetzen

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

## Betriebssystem konfigurieren

```Shell
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false

gsettings set org.gnome.desktop.interface menus-have-icons true
gsettings set org.gnome.desktop.interface buttons-have-icons true

gsettings set org.gtk.Settings.FileChooser show-hidden true
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
gsettings set org.gnome.nautilus.list-view default-visible-columns "['name', 'owner', 'group', 'permissions']"
```

### Ubuntu 18.04
```Shell
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
```

### Ubuntu 16.04
```Shell
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set com.canonical.indicator.session show-real-name-on-panel true
gsettings set com.canonical.Unity integrated-menus true
```

* Ubuntu 16.04: System Settings > Security & Privacy > Files & Applications > Record file and application usage = Off

### Optional: Watcher für Änderungen an der Konfiguration
Für weitere Konfiguration, kann man diese Tools verwenden.

```Shell
dconf watch /
sudo apt -y install dconf-editor
gsettings list-recursively | grep search
```

## Configure Bash (User & Root)

```Shell
sudo cp /home/user/Desktop/dev-vm-linux/home/user/.bashrc-user /root/
gedit ~/.bashrc && sudo gedit /root/.bashrc
```

* Zur .bashrc hinzufügen

```Shell
source ~/.bashrc-user
```

## Configure Zsh (User & Root)

```Shell
sudo apt -y install zsh
sudo rsync -av /home/user/Desktop/dev-vm-linux/home/user/.zshrc /root/
sudo rsync -av /home/user/Desktop/dev-vm-linux/home/user/.oh-my-zsh/ /root/.oh-my-zsh/
git clone https://github.com/robbyrussell/oh-my-zsh.git /tmp/.oh-my-zsh

rsync -av /tmp/.oh-my-zsh/ ~/.oh-my-zsh/
sudo rsync -av /tmp/.oh-my-zsh/ /root/.oh-my-zsh/
```

## DNS Server (example.vm)

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
sudo sh -c 'echo "address=/.vm/127.0.0.1" >> /etc/NetworkManager/dnsmasq.d/development'
sudo systemctl restart network-manager
sudo resolvconf -u
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

sudo rsync -av /home/user/Desktop/dev-vm-linux/etc/apache2/conf-available/ /etc/apache2/conf-available/
sudo rsync -av /home/user/Desktop/dev-vm-linux/etc/apache2/sites-available/ /etc/apache2/sites-available/
sudo cp /home/user/Desktop/dev-vm-linux/etc/apache2/ports.conf /etc/apache2/
sudo chown -R user:user /etc/apache2/sites-available
sudo chown -R user:user /etc/apache2/sites-enabled
sudo usermod -aG adm ${USER}

sudo chmod 0775 /var/www
sudo chown -R user:user /var/www
sudo find /var/www -type d -exec chmod 775 {} \;
sudo find /var/www -type f -exec chmod 664 {} \;
sudo find /var/www -type d -exec chmod g+s {} \;

sudo gedit /etc/apache2/envvars
```

* Datei envvars anpassen

```Text
export APACHE_RUN_USER=user
export APACHE_RUN_GROUP=user
```

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
sudo rsync -av /home/user/Desktop/dev-vm-linux/etc/nginx/sites-available/ /etc/nginx/sites-available/
sudo rsync -av /home/user/Desktop/dev-vm-linux/etc/nginx/snippets/ /etc/nginx/snippets/
sudo chown -R user:user /etc/nginx/sites-available
sudo chown -R user:user /etc/nginx/sites-enabled
sudo chown -R user:user /etc/nginx/snippets

sudo gedit /etc/nginx/nginx.conf
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
sudo gedit /etc/nginx/snippets/fastcgi-php.conf
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
gedit ~/.bashrc && gedit ~/.zshrc
```

* Dateien .bashrc & .zshrc am Ende hinzufügen

```Shell
source /home/user/.phpbrew/bashrc
```

* Reboot

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

gedit /home/user/.phpbrew/php/php-7.2.5/etc/php.ini
gedit /home/user/.phpbrew/php/php-7.1.17/etc/php.ini
gedit /home/user/.phpbrew/php/php-7.0.30/etc/php.ini
gedit /home/user/.phpbrew/php/php-5.6.36/etc/php.ini
gedit /home/user/.phpbrew/php/php-5.5.38/etc/php.ini
gedit /home/user/.phpbrew/php/php-5.4.45/etc/php.ini
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

[mail function]
sendmail_path = /usr/bin/env /usr/local/bin/catchmail -t -f 'www-data@localhost'
;sendmail_path = /usr/sbin/sendmailfake
```

* PHP <= 5.6

```INI
[PHP]
always_populate_raw_post_data = -1
```

### PhpBrew - Configure PHP extension xDebug

```Shell
cp snippets/xdebug.ini /home/user/.phpbrew/php/php-7.2.5/var/db/
cp snippets/xdebug.ini /home/user/.phpbrew/php/php-7.1.17/var/db/
cp snippets/xdebug.ini /home/user/.phpbrew/php/php-7.0.30/var/db/
cp snippets/xdebug.ini /home/user/.phpbrew/php/php-5.6.36/var/db/
cp snippets/xdebug.ini /home/user/.phpbrew/php/php-5.5.38/var/db/
cp snippets/xdebug.ini /home/user/.phpbrew/php/php-5.4.45/var/db/

gedit /home/user/.phpbrew/php/php-5.4.45/var/db/xdebug.ini
```

* Konfiguration für PHP 5.4 anpassen

```INI
zend_extension=/home/user/.phpbrew/php/php-5.4.45/lib/php/extensions/no-debug-non-zts-20100525/xdebug.so
```

* Disable xDebug (N)

```Shell
/home/user/Desktop/xdebug.sh
```

### PhpBrew autostart
```Shell
sudo gedit /etc/crontab
```

* Datei crontab anpassen

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
sudo gedit /etc/mysql/my.cnf
```

* Datei my.cnf hinzufügen

```INI
[client]
user=root
password=root
default-character-set=utf8
pager=less -FSRX

[mysqld]
collation-server=utf8_unicode_ci
init-connect='SET NAMES utf8'
character-set-server=utf8
bind-address=127.0.0.1
sql_mode=""
#sql_mode="ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"

[mysql]
default-character-set=utf8
```

```Shell
sudo service mysql restart
```

###  MySQL - Zugriff von normalen Benutzer ermöglichen
```Shell
sudo mysql
```

* SQL ausführen

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
sudo cp /home/user/Desktop/dev-vm-linux/usr/sbin/sendmailfake /usr/sbin/
```

## MailCachter
https://mailcatcher.me/

```Shell
sudo apt -y install build-essential libsqlite3-dev ruby-dev

sudo gem install mailcatcher

sudo gedit /etc/crontab
```

* Datei crontab hinzufügen

```Text
@reboot root $(which mailcatcher) --ip=0.0.0.0
```

### MailCachter - System PHP

```Shell
# Ubuntu 18.04
sudo gedit /etc/php/7.2/mods-available/mailcatcher.ini

# Ubuntu 16.04
sudo gedit /etc/php/7.0/mods-available/mailcatcher.ini
```

* Datei mailcatcher.ini hinzufügen

```Text
sendmail_path = /usr/bin/env /usr/local/bin/catchmail -t -f 'www-data@localhost'
;sendmail_path = /usr/sbin/sendmailfake
```

```Shell
sudo phpenmod mailcatcher
```

* Reboot

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
sudo rsync -av var/www/ /var/www/

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

## Firefox Browser
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
sudo gedit /etc/samba/smb.conf
sudo smbpasswd -a user
# Password: user
sudo service smbd restart
```

### Samba /etc/samba/smb.conf

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

## HeidiSQL

* https://www.heidisql.com/
* https://www.chiark.greenend.org.uk/~sgtatham/putty/

```Shell
wget -O ~/Downloads/HeidiSQL.exe https://www.heidisql.com/installers/HeidiSQL_9.5.0.5196_Setup.exe
wget -O ~/Downloads/putty.msi https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.70-installer.msi

sudo apt -y install playonlinux
```

Open PlayOnLinux and create a new virtual drive

* Tools > Manage Wine versions > Install latest 64 bit Wine version (current: 3.7)

* Configure > New > 64 bit latest Wine Version (Container name: HeidiSQL)
* Select Container
	- Wine > Configure Wine > Application > Windows Version: Windows XP
    - Miscellaneous > Run a .exe file in this virtual drive > Install HeidiSQL & Putty
	- General > Make a new shortcut from this virtual drive > heidisql.exe > Shortcut name: HeidiSQL

Remove HeidiSQL created Shortcut and convert icon from executable

```Shell
rm ~/Downloads/HeidiSQL.exe ~/Desktop/HeidiSQL.desktop ~/Desktop/HeidiSQL.lnk ~/Downloads/putty.msi

# Maybe Bug on Ubuntu 16.04
wrestool -x -t14 --name=MAINICON ~/.PlayOnLinux/wineprefix/HeidiSQL/drive_c/Program\ Files/HeidiSQL/heidisql.exe > ~/.PlayOnLinux/wineprefix/HeidiSQL/drive_c/Program\ Files/HeidiSQL/heidisql.ico
```

Open HeidiSQL and create new session

* Session Name: Localhost
* Hostname / IP: 127.0.0.1
* User: root
* Password: root
* Port: 3306

Connect Server Localhost in HeidiSQL and configure it

* Tools > Preferences > SQL > Editor font: Liberation Mono, 10pt

## Ubuntu 16.04: Keine Dialogbox bei automatischem Herunterfahren anzeigen
sudo gedit /etc/acpi/powerbtn.sh
Am Anfang vom Script:
```Shell
/sbin/shutdown -h now 'Power button pressed' && exit 0
```

### Optional: Set Wallpaper
Kann selbstverständlich auch über Einstellungen konfiguriert werden.

```Shell
ls /home/user/Pictures

gsettings set org.gnome.desktop.background picture-uri "file:///home/user/Pictures/wallpaper.jpg"
gsettings set org.gnome.desktop.background picture-options 'zoom'
```

* Ubuntu 18.04 zusätzlich für Sperrbildschirm

```Shell
gsettings set org.gnome.desktop.screensaver picture-uri "file:///home/user/Pictures/wallpaper.jpg"
gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
```

## Cleanups

* Gemeinsame Ordner: entfernen

```Shell
sudo chown -R user:user /etc/apache2/sites-available
sudo chown -R user:user /etc/apache2/sites-enabled
sudo chown -R user:user /etc/nginx/sites-available
sudo chown -R user:user /etc/nginx/sites-enabled

sudo rm /home/user/.local/share/recently-used.xbel

rm -rf /home/user/Desktop/dev-vm-linux

# Ubuntu 18.04
gio trash --empty

# Ubuntu 16.04
gvfs-trash --empty

sudo apt update && sudo apt -y dist-upgrade && sudo apt -y autoremove

# Both Ubuntu...
sudo /opt/VBoxGuestAdditions-*/uninstall.sh

sudo su
rm /home/user/.mysql_history
rm /home/user/.bash_history
rm /home/user/.zsh_history
rm /root/.mysql_history
rm /root/.bash_history
rm /root/.zsh_history
reboot
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

* Virtualbox > Datei > Appliance exportieren
  - Open Virtualization Format 2.0
