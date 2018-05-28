# Entwicklungsumgebung als Virtuelle Maschine

## Virtualbox - neue Virtuelle Maschine erstellen
* Name: UbuntuDev
* RAM: 4096 MB
* Keine Festplatte

* Allgemein > Erweitert > Gemeinsame Zwischenablage + Drag & Drop: bidirektional
* System > Hauptplatine > Boot-Reihenfolge > DVD, Platte
* System > Prozessor > CPU: 4 (Maximale von grün)
* Massenspeicher > SATA Port 0, HDD, Filename: System, 80 GB, VDMK, dynamisch alloziert, Name: System
* Massenspeicher > SATA Port 2, Compact Disc, Betriebssystem einlegen
* Audio deactivated
* Netzwerk > Network 1, NAT
* Netzwerk > Network 2, Netzwerkbrücke, eth1
* Gemeinsamer Ordner setzen

## Ubuntu [16.04 | 18.04] installieren

* Ubuntu 18.04: Full installation

* Your name: user
* Computer name: dev-vm
* Username: user
* Passwort: user
* Log in automatically = true

* Gast-Erweiterung installieren & neustarten
* System Settings > Displays > Resolution 1280x800
* Icons: Nautilus, Firefox, Terminal

```Shell
sudo passwd root
```

* Root Passwort: root

```Shell
sudo add-apt-repository multiverse
sudo apt update
sudo apt -y dist-upgrade
sudo apt -y install curl git gparted htop meld nautilus-compare openssh-server \
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

## Achiv erstellen
Zu kopierende Dateien Archiv erstellen.

```Shell
tar cfz install-development.tar.gz install-development
```

## Achiv entpacken
 Dateien in die Virtuelle Maschine kopieren & entpacken, bei Neustarts Terminal in dem Ordner öffnen.

```Shell
tar xf install-development.tar.gz && rm install-development.tar.gz && cd install-development
rsync -av home/user/ /home/user/
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
sudo cp home/user/.bashrc-user /root/
gedit ~/.bashrc && sudo gedit /root/.bashrc
```

* Zur .bashrc hinzufügen

```Shell
source ~/.bashrc-user
```

## Configure Zsh (User & Root)

```Shell
sudo apt -y install zsh
sudo rsync -av home/user/.zshrc /root/
sudo rsync -av home/user/.oh-my-zsh/ /root/.oh-my-zsh/
git clone https://github.com/robbyrussell/oh-my-zsh.git /tmp/.oh-my-zsh

rsync -av /tmp/.oh-my-zsh/ ~/.oh-my-zsh/
sudo rsync -av /tmp/.oh-my-zsh/ /root/.oh-my-zsh/
```

## DNS (example.vm)

```Shell
# sudo apt install resolvconf
sudo gedit /etc/NetworkManager/NetworkManager.conf
```

* Zur Datei hinzufügen: /etc/NetworkManager/NetworkManager.conf

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

sudo rsync -av etc/apache2/conf-available/ /etc/apache2/conf-available/
sudo rsync -av etc/apache2/sites-available/ /etc/apache2/sites-available/
sudo cp etc/apache2/ports.conf /etc/apache2/
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
sudo rsync -av etc/nginx/sites-available/ /etc/nginx/sites-available/
sudo rsync -av etc/nginx/snippets/ /etc/nginx/snippets/
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
sudo cp usr/sbin/sendmailfake /usr/sbin/
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

## Ubuntu 16.04: Docker
https://docs.docker.com/install/linux/docker-ce/ubuntu/

```Shell
sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# stable, edge, nightly
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) edge"
sudo apt update
sudo apt -y install docker-ce
sudo usermod -aG docker ${USER}
sudo reboot
```

# Ubuntu 16.04: Docker Compose
https://docs.docker.com/compose/install/#install-compose
https://github.com/docker/compose/releases

```Shell
sudo curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Ubuntu 16.04: Docker Test

```Shell
docker run hello-world
docker ps -a
docker rm 4e68562f6510
docker images -a
docker rmi 05a3bd381fc2
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

* Startmenü > PlayOnLinux

* Tools > Manage Wine versions > Install latest 64 bit Wine version (current: 3.7)

* Configure > New > 64 bit latest Wine Version (Container name: HeidiSQL)
* Select Container
	- Wine > Configure Wine > Application > Windows Version: Windows XP
    - Miscellaneous > Run a .exe file in this virtual drive > Install HeidiSQL & Putty
	- General > Make a new shortcut from this virtual drive > heidisql.exe > Shortcut name: HeidiSQL

* Remove HeidiSQL created Shortcut, Convert icon from executable

```Shell
rm ~/Downloads/HeidiSQL.exe ~/Desktop/HeidiSQL.desktop ~/Desktop/HeidiSQL.lnk ~/Downloads/putty.msi

# Maybe Bug on Ubuntu 16.04
wrestool -x -t14 --name=MAINICON ~/.PlayOnLinux/wineprefix/HeidiSQL/drive_c/Program\ Files/HeidiSQL/heidisql.exe > ~/.PlayOnLinux/wineprefix/HeidiSQL/drive_c/Program\ Files/HeidiSQL/heidisql.ico
```

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

```Shell
sudo chown -R user:user /etc/apache2/sites-available
sudo chown -R user:user /etc/apache2/sites-enabled
sudo chown -R user:user /etc/nginx/sites-available
sudo chown -R user:user /etc/nginx/sites-enabled

sudo rm /home/user/.local/share/recently-used.xbel

sudo apt update && sudo apt -y dist-upgrade && sudo apt -y autoremove
```

* Remove install-development folder
* Gemeinsame Ordner: entfernen

```Shell
# Ubuntu 18.04
gio trash --empty

# Ubuntu 16.04
gvfs-trash --empty

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

## Virtualbox export
* Virtualbox > Datei > Appliance exportieren
* Hersteller: Hot Example
* Hersteller-URL: https://example.org/
* Open Virtualization Format 2.0

## Virtualbox import
* Virtualbox > Datei > Appliance importieren
* CPU: 4 (Maximale von grün)
* RAM: 2048 oder 4096 MB

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
sudo mkdir /media/data
sudo blkid | grep sdb

sudo gedit /etc/fstab
```

* Datei fstab anpassen

```Text
UUID=288132af-be1e-4a3a-a2b6-1210c9816f50 /media/data               ext4    errors=remount-ro 0       1
```

* Startmenü > Terminal

```Shell
sudo mount /media/data
sudo chmod 777 /media/data
```

### HDD2 - Move Webserver

```Shell
sudo mkdir -p /media/data/var/www
sudo chown -R user:user /media/data/var
sudo chmod 775 /media/data/var/www
sudo chmod g+s /media/data/var/www

sudo mv /var/www/!(.|..) /media/data/var/www/
sudo rmdir /var/www
sudo ln -s /media/data/var/www /var/
```

### HDD2 - Move MySQL

```Shell
sudo service mysql stop
sudo mkdir -p /media/data/var/lib
sudo mv /var/lib/mysql /media/data/var/lib/
sudo ln -s /media/data/var/lib/mysql /var/lib/mysql

sudo gedit /etc/apparmor.d/tunables/alias
```

* Datei alias anpassen

```Text
alias /var/lib/mysql/ -> /media/data/var/lib/mysql/,
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
puttygen ~/.ssh/id_rsa -o /var/www/id_rsa.ppk
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

### Samba/Windows Freigabe
Der /var/www Ordner ist erreichbar über www.
IP-Adresse muss außerhalb der virtuellen Maschine angepasst werden.

#### Samba/Windows Freigabe - Windows konfiguration
Command öffnen (STRG + R -> cmd)

```Shell
net use Z: \\127.0.0.1\www /PERSISTENT:YES
```

#### Samba/Windows Freigabe - Linux konfiguration

```Shell
sudo apt install sshfs cifs-utils
sudo mkdir -p /media/samba/vm
sudo chmod 777 /media/samba/vm

sudo /etc/fstab
```

* Zur Datei /etc/fstab hinzufügen:

```Text
//127.0.0.1/www /media/samba/vm cifs uid=localUsername,username=user,password=user 0 0
```

### Php Version wechseln

```Shell
# Installierte PHP Versionen anzeigen
phpbrew list

# PHP Version dauerhaft im Terminal wechseln
phpbrew switch php-7.2.3

# PHP Version temporär im Terminal wechseln
phpbrew use php-7.2.3

# PHP Version anzeigen
php -v
```

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
