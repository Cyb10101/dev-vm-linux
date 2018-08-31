#!/bin/bash

rebootRequired() {
	echo '';
	echo "Reboot required: ${1}";
	read -p 'Reboot? [y/N] ' -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		sudo reboot
	fi
}

rebootRequiredForce() {
	echo '';
	echo "Reboot required: ${1}";
	read -p 'Reboot? [Y/n] ' -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Nn]$ ]]; then
		sudo reboot
	fi
}

appendBashRcFile() {
	array=(
		'source ~/.shell-methods'
		'#sshAgentRestart'
		'#sshAgentAddKey 24h ~/.ssh/id_rsa'
		'addAlias'
		'stylePS1'
		'#terminalMotd'
	)
	for id in ${!array[*]}; do
		if [[ ${1} == 'root' ]]; then
			sudo sh -c "echo \"${array[$id]}\" >> ${2}"
		else
			echo "${array[$id]}" >> ${2}
		fi
	done
}

runInstallRequirements() {
	# Install requirements
	sudo add-apt-repository -y multiverse
	sudo apt update

	echo '';
	echo 'If you use german keyboard layout install the language pack.';
	read -p 'Install german language pack? [Y/n] ' -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Nn]$ ]]; then
	    sudo apt -y install language-pack-de
	fi

	sudo apt -y dist-upgrade

	sudo apt -y install curl htop putty-tools whois net-tools resolvconf
}

copyFiles() {
	# Copy files
	rsync -a /home/user/dev-vm-linux/home/user/ /home/user/
	sudo rsync -a /home/user/dev-vm-linux/usr/local/bin/ /usr/local/bin/
}

configureGrub() {
	# Configure Grub
	if [[ $(lsb_release -rs) == '18.04' ]]; then
		sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="maybe-ubiquity consoleblank=0"/' /etc/default/grub
	fi;
	if [[ $(lsb_release -rs) == '16.04' ]]; then
		sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="consoleblank=0"/' /etc/default/grub
	fi;
	sudo update-grub
}

configureBash() {
	# Bash (User & Root)
	sudo cp /home/user/dev-vm-linux/home/user/.shell-methods /root/
	appendBashRcFile 'user' ~/.bashrc
	appendBashRcFile 'root' /root/.bashrc
}

installZsh() {
	# Zsh (User & Root)
	sudo apt -y install zsh
	sudo rsync -a /home/user/dev-vm-linux/home/user/.zshrc /root/
	sudo rsync -a /home/user/dev-vm-linux/home/user/.oh-my-zsh/ /root/.oh-my-zsh/
	git clone https://github.com/robbyrussell/oh-my-zsh.git /tmp/.oh-my-zsh

	rsync -a /tmp/.oh-my-zsh/ ~/.oh-my-zsh/
	sudo rsync -a /tmp/.oh-my-zsh/ /root/.oh-my-zsh/
	sudo chown -R root:root /root/.oh-my-zsh
	sudo chown root:root /root/.zshrc

	## Message of the day - Disable to much information
	sudo chmod -x /etc/update-motd.d/10-help-text

	# Ubuntu 16.04:
	if [[ $(lsb_release -rs) == '16.04' ]]; then
		sudo chmod -x /etc/update-motd.d/91-release-upgrade
	fi;

	## Message of the day - Keep me from working
	sudo apt -y install boxes lolcat fortune-mod fortunes fortunes-min fortunes-de fortunes-ubuntu-server fortunes-bofh-excuses
	sudo chmod -x /etc/update-motd.d/60-ubuntu-server-tip

	# DNS Server (example.vm)
	if [[ $(lsb_release -rs) == '18.04' ]]; then
		sudo sh -c 'echo "127.0.1.1    dev-vm" >> /etc/hosts'
	fi;

	## Install & configure Dnsmasq
	sudo apt -y install dnsmasq
	sudo sh -c 'echo "nameserver 127.0.1.1" >> /etc/resolvconf/resolv.conf.d/head'
	sudo sh -c 'echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/head'
	sudo sh -c 'echo "address=/.vm/127.0.0.1" >> /etc/dnsmasq.conf'

	if [[ $(lsb_release -rs) == '18.04' ]]; then
		sudo rsync -a /home/user/dev-vm-linux/etc/netplan/ /etc/netplan/
		sudo service dnsmasq restart
		sudo netplan generate && sudo netplan apply
	fi;
	if [[ $(lsb_release -rs) == '16.04' ]]; then
		sudo service dnsmasq restart
	fi;
	sudo resolvconf -u

	echo '';
	read -p 'Test DNS Server? [Y/n] ' -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Nn]$ ]]; then
		# Test resolv.conf
		cat /etc/resolv.conf
		ping -c 4 example.vm
		read -n 1 -s -r -p 'Press any key to continue...'

		if [[ $(lsb_release -rs) == '18.04' ]]; then
			systemd-resolve --status
			read -n 1 -s -r -p 'Press any key to continue...'
		fi;
		echo
	fi
}

installApache2() {
	# System Webserver (Apache)
	sudo apt -y install apache2 php libapache2-mod-php php-fpm

	if [[ $(lsb_release -rs) == '18.04' ]]; then
		sudo a2enconf php7.2-fpm
	fi;
	if [[ $(lsb_release -rs) == '16.04' ]]; then
		sudo a2enconf php7.0-fpm
	fi;

	sudo a2enmod actions alias deflate expires headers macro rewrite proxy proxy_fcgi ssl vhost_alias

	sudo apt -y install imagemagick graphicsmagick
	# sudo apt -y install graphicsmagick graphicsmagick-imagemagick-compat

	sudo rsync -a /home/user/dev-vm-linux/etc/apache2/conf-available/ /etc/apache2/conf-available/
	sudo rsync -a /home/user/dev-vm-linux/etc/apache2/sites-available/ /etc/apache2/sites-available/
	sudo cp /home/user/dev-vm-linux/etc/apache2/ports.conf /etc/apache2/
	sudo chown -R user:user /etc/apache2/sites-available
	sudo chown -R user:user /etc/apache2/sites-enabled
	sudo usermod -aG adm ${USER}

	sudo chmod 0775 /var/www
	sudo chown -R user:user /var/www
	sudo find /var/www -type d -exec chmod 775 {} \;
	sudo find /var/www -type f -exec chmod 664 {} \;
	sudo find /var/www -type d -exec chmod g+s {} \;

	sudo sed -i 's/^export APACHE_RUN_USER=.*/export APACHE_RUN_USER=user/' /etc/apache2/envvars
	sudo sed -i 's/^export APACHE_RUN_GROUP=.*/export APACHE_RUN_GROUP=user/' /etc/apache2/envvars

	# Enable configuration and websites
	sudo a2enconf macro-fancy-indexing.conf
	sudo a2enconf macro-virtual-host-defaults.conf
	sudo a2enconf macro-virtual-host-ssl.conf
	sudo a2enconf phpbrew.conf
	sudo a2enconf server-name.conf
	sudo a2ensite apache-demo.conf
	sudo a2ensite zzz-wildcard-vm.conf
	sudo a2ensite zzz-wildcard-company.conf
	sudo apache2ctl configtest && sudo systemctl restart apache2
}

installNginx() {
	# Install Nginx
	sudo apt -y install nginx nginx-extras
	sudo rsync -a /home/user/dev-vm-linux/etc/nginx/conf.d/ /etc/nginx/conf.d/
	sudo rsync -a /home/user/dev-vm-linux/etc/nginx/sites-available/ /etc/nginx/sites-available/
	sudo rsync -a /home/user/dev-vm-linux/etc/nginx/snippets/ /etc/nginx/snippets/
	sudo chown -R user:user /etc/nginx/sites-available
	sudo chown -R user:user /etc/nginx/sites-enabled
	sudo chown -R user:user /etc/nginx/snippets

	# Configure Nginx
	sudo sed -i 's/^user www-data;$/user user;/' /etc/nginx/nginx.conf
	sudo sh -c 'echo "fastcgi_param TYPO3_CONTEXT Development/YourName;" >> /etc/nginx/snippets/fastcgi-php.conf'
	sudo sh -c 'echo "fastcgi_param FLOW_CONTEXT Development/YourName;" >> /etc/nginx/snippets/fastcgi-php.conf'
	sudo sh -c 'echo "fastcgi_param WWW_CONTEXT Development/YourName;" >> /etc/nginx/snippets/fastcgi-php.conf'
	sudo sh -c 'echo "fastcgi_param SERVER_NAME \$host;" >> /etc/nginx/snippets/fastcgi-php.conf'

	# Enable configuration and websites
	sudo ln -s /etc/nginx/sites-available/apache-proxy /etc/nginx/sites-enabled/
	sudo ln -s /etc/nginx/sites-available/nginx-demo /etc/nginx/sites-enabled/
	sudo ln -s /etc/nginx/sites-available/zzz-wildcard /etc/nginx/sites-enabled/
	sudo nginx -t && sudo systemctl restart nginx
}

installPhpBrew() {
	curl -L -O https://github.com/phpbrew/phpbrew/raw/master/phpbrew
	chmod +x phpbrew
	sudo mv phpbrew /usr/local/bin/phpbrew
	phpbrew init
	phpbrew update

	echo 'source /home/user/.phpbrew/bashrc' >> /home/user/.bashrc
	echo 'source /home/user/.phpbrew/bashrc' >> /home/user/.zshrc
}

installPhpBrewRequirements() {
	sudo chmod -R oga+rw /usr/lib/apache2/modules
	sudo chmod -R oga+rw /etc/apache2

	sudo apt -y install autoconf apache2-dev libxml2-dev libcurl4-openssl-dev pkg-config libssl-dev libbz2-dev libjpeg-turbo8-dev libpng-dev libxpm-dev libfreetype6-dev libmcrypt4 libmcrypt-dev libpq-dev libreadline-dev libtidy-dev libxslt1-dev

	# Argon2 Password Hash (Ubuntu 18.04, PHP 7.2+)
	if [[ $(lsb_release -rs) == '18.04' ]]; then
		sudo apt install argon2 libargon2-0 libargon2-0-dev
	fi;
}

phpBrewCompile-php-7.2.5Argon2() {
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
		--with-xpm-dir=/usr \
		--with-password-argon2
}

phpBrewCompile-php() {
	phpbrew install -j $(nproc) ${1} \
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
}

phpBrewExtensionGd() {
	phpbrew extension install gd -- \
			--enable-gd-native-ttf \
			--with-gd=shared \
			--with-freetype-dir=/usr/include/freetype2/freetype \
			--with-jpeg-dir=/usr \
			--with-libdir=lib/x86_64-linux-gnu \
			--with-png-dir=/usr \
			--with-vpx-dir=/usr \
			--with-xpm-dir=/usr
}

phpBrewExtension-php-7() {
	phpBrewExtensionGd
	phpbrew extension install opcache
	phpbrew extension install apcu
	phpbrew extension install xdebug 2.6.0
}

phpBrewExtension-php-5() {
	phpBrewExtensionGd
	phpbrew extension install opcache
	phpbrew extension install xdebug 2.5.5
}

phpBrewCompile-php-5.4.45() {
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

	phpbrew extension install gd -- \
		--enable-gd-native-ttf \
		--with-gd=shared \
		--with-freetype-dir=/usr/include/freetype2/freetype \
		--with-jpeg-dir=/usr \
		--with-libdir=lib/x86_64-linux-gnu \
		--with-png-dir=/usr \
		--with-xpm-dir=/usr

	phpbrew extension install xdebug 2.4.1
}

configurePhpIni() {
	sed -i 's/^error_reporting =.*/error_reporting = E_ALL/' /home/user/.phpbrew/php/${1}/etc/php.ini
	sed -i 's/^display_errors =.*/display_errors = On/' /home/user/.phpbrew/php/${1}/etc/php.ini

	sed -i 's/^max_execution_time =.*/max_execution_time = 300/' /home/user/.phpbrew/php/${1}/etc/php.ini
	sed -i 's/^max_input_time =.*/max_input_time = 600/' /home/user/.phpbrew/php/${1}/etc/php.ini
	sed -i 's/^; max_input_vars =.*/max_input_vars = 2000/' /home/user/.phpbrew/php/${1}/etc/php.ini
	sed -i 's/^memory_limit =.*/memory_limit = 2048M/' /home/user/.phpbrew/php/${1}/etc/php.ini

	sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 200M/' /home/user/.phpbrew/php/${1}/etc/php.ini
	sed -i 's/^post_max_size =.*/post_max_size = 200M/' /home/user/.phpbrew/php/${1}/etc/php.ini

	sed -i 's/^;date.timezone =.*/date.timezone = Europe\/Berlin/' /home/user/.phpbrew/php/${1}/etc/php.ini

	sed -i 's/^mysqli.default_host =.*/mysqli.default_host = 127.0.0.1/' /home/user/.phpbrew/php/${1}/etc/php.ini

	sed -i "s/^;sendmail_path =.*/sendmail_path = \/usr\/bin\/env \/usr\/local\/bin\/catchmail -t -f 'www-data@localhost'/" /home/user/.phpbrew/php/${1}/etc/php.ini

	sed -i 's/^session.gc_maxlifetime =.*/session.gc_maxlifetime = 86400/' /home/user/.phpbrew/php/${1}/etc/php.ini
}
configurePhpIniPhp5() {
	sed -i "s/^;always_populate_raw_post_data =.*/always_populate_raw_post_data = -1/" /home/user/.phpbrew/php/${1}/etc/php.ini

	sed -i 's/^mysql.default_host =.*/mysql.default_host = 127.0.0.1/' /home/user/.phpbrew/php/${1}/etc/php.ini
}

configurePhpXdebug() {
	cp /home/user/dev-vm-linux/snippets/xdebug.ini /home/user/.phpbrew/php/${1}/var/db/
}
configurePhpXdebug-php-5.4.45() {
	sed -i 's/^zend_extension=.*/zend_extension=\/home\/user\/.phpbrew\/php\/php-5.4.45\/lib\/php\/extensions\/no-debug-non-zts-20100525\/xdebug.so/' /home/user/.phpbrew/php/php-5.4.45/var/db/xdebug.ini
}

### PhpBrew FPM configuration
configurePhpFpm7() {
	sed -i 's/^user = nobody$/;user = nobody/' /home/user/.phpbrew/php/${1}/etc/php-fpm.d/www.conf
	sed -i 's/^group = nobody$/;group = nobody/' /home/user/.phpbrew/php/${1}/etc/php-fpm.d/www.conf
}
configurePhpFpm5() {
	sed -i 's/^user = nobody$/;user = nobody/' /home/user/.phpbrew/php/${1}/etc/php-fpm.conf
	sed -i 's/^group = nobody$/;group = nobody/' /home/user/.phpbrew/php/${1}/etc/php-fpm.conf
}

phpBrewAutostart() {
	sudo sh -c 'echo "@reboot user /home/user/.start-php-fpm.sh" >> /etc/crontab'
}

phpBrewBugfix() {
	sudo a2dismod php5
	sudo a2dismod php7
	if [[ $(lsb_release -rs) == '18.04' ]]; then
		sudo a2dismod php7.2
	fi;
	if [[ $(lsb_release -rs) == '16.04' ]]; then
		sudo a2dismod php7.0
	fi;
}

phpBrewBuild() {
	# PHP 7.2.5
	if [[ $(lsb_release -rs) == '18.04' ]]; then
		phpBrewCompile-php-7.2.5Argon2
		# @todo On build error 'a2enmod php7' retry once
		phpBrewCompile-php-7.2.5Argon2
	fi;
	if [[ $(lsb_release -rs) == '16.04' ]]; then
		phpBrewCompile-php 'php-7.2.5'
		# @todo On build error 'a2enmod php7' retry once
		phpBrewCompile-php 'php-7.2.5'
	fi;

	phpbrew use php-7.2.5
	phpBrewExtension-php-7

	# PHP 7.1.17
	phpBrewCompile-php 'php-7.1.17'
	phpbrew use php-7.1.17
	phpBrewExtension-php-7

	# PHP 7.0.30
	phpBrewCompile-php 'php-7.0.30'
	phpbrew use php-7.0.30
	phpBrewExtension-php-7

	if [[ $(lsb_release -rs) == '16.04' ]]; then
		sudo apt -y install libvpx-dev

		# PHP 5.6.36
		phpBrewCompile-php 'php-5.6.36'
		# @todo On build error 'a2enmod php5' retry once
		phpBrewCompile-php 'php-5.6.36'

		phpbrew use php-5.6.36
		phpBrewExtension-php-5

		# PHP 5.5.38
		phpBrewCompile-php 'php-5.5.38'
		phpbrew use php-5.5.38
		phpBrewExtension-php-5

		# PHP 5.4.45
		phpBrewCompile-php-5.4.45
	fi;

	phpbrew switch php-7.2.5
}

phpBrewConfigure() {
	# Configure PHP
	configurePhpIni 'php-7.2.5'
	configurePhpIni 'php-7.1.17'
	configurePhpIni 'php-7.0.30'
	if [[ $(lsb_release -rs) == '16.04' ]]; then
		configurePhpIni 'php-5.6.36'
		configurePhpIniPhp5 'php-5.6.36'

		configurePhpIni 'php-5.5.38'
		configurePhpIniPhp5 'php-5.5.38'

		configurePhpIni 'php-5.4.45'
		configurePhpIniPhp5 'php-5.4.45'
	fi;

	# Configure PHP xDebug
	configurePhpXdebug 'php-7.2.5'
	configurePhpXdebug 'php-7.1.17'
	configurePhpXdebug 'php-7.0.30'
	if [[ $(lsb_release -rs) == '16.04' ]]; then
		configurePhpXdebug 'php-5.6.36'
		configurePhpXdebug 'php-5.5.38'
		configurePhpXdebug 'php-5.4.45'
		configurePhpXdebug-php-5.4.45
	fi;
	/usr/local/bin/xdebug

	# Configure PHP FPM
	configurePhpFpm7 'php-7.2.5'
	configurePhpFpm7 'php-7.1.17'
	configurePhpFpm7 'php-7.0.30'
	if [[ $(lsb_release -rs) == '16.04' ]]; then
		configurePhpFpm5 'php-5.6.36'
		configurePhpFpm5 'php-5.5.38'
		configurePhpFpm5 'php-5.4.45'
	fi;

	# PhpBrew other
	phpBrewAutostart
	phpBrewBugfix
}

installMySQL() {
	echo debconf mysql-server/root_password password 'root' | sudo debconf-set-selections
	echo debconf mysql-server/root_password_again password 'root' | sudo debconf-set-selections
	sudo apt -y install mysql-server php-mysql

	sudo cp /home/user/dev-vm-linux/etc/mysql/mysql.conf.d/zzz-development.cnf /etc/mysql/mysql.conf.d/
	sudo service mysql restart

	mysql <<EOF
SELECT host, user FROM mysql.user;
DROP USER 'root'@'%';
DROP USER 'root'@'localhost';
CREATE USER 'root'@'%' IDENTIFIED BY 'root';
CREATE USER 'root'@'localhost' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
}

installFakeMail() {
	sudo apt -y install tofrodos ack-grep
	sudo cp /home/user/dev-vm-linux/usr/sbin/sendmailfake /usr/sbin/
}

installMailCatcher() {
	sudo apt -y install build-essential libsqlite3-dev ruby-dev
	sudo gem install mailcatcher
	sudo sh -c 'echo "@reboot root \$(which mailcatcher) --ip=0.0.0.0" >> /etc/crontab'

	if [[ $(lsb_release -rs) == '18.04' ]]; then
		sudo rsync -a /home/user/dev-vm-linux/etc/php/7.0/mods-available/mailcatcher.ini /etc/php/7.2/mods-available/
	fi;
	if [[ $(lsb_release -rs) == '16.04' ]]; then
		sudo rsync -a /home/user/dev-vm-linux/etc/php/7.0/mods-available/mailcatcher.ini /etc/php/7.0/mods-available/
	fi;

	sudo phpenmod mailcatcher
}

installComposer() {
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
	php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
	php composer-setup.php
	php -r "unlink('composer-setup.php');"
	sudo mv composer.phar /usr/local/bin/composer
}

installWebsite() {
	sudo rm -rf /var/www/html
	sudo rsync -a /home/user/dev-vm-linux/var/www/ /var/www/

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
}

installDocker() {
	sudo apt -y install apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	sudo apt update
	sudo apt -y install docker-ce
	sudo usermod -aG docker ${USER}
}

installDockerCompose() {
	sudo curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
}

runDockerTest() {
	echo '';
	read -p 'Test Docker? [Y/n] ' -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Nn]$ ]]; then
		# Run hello world test
		docker run hello-world

		# Delete all container
		docker rm $(docker ps -a -q)

		# Delete all images
		docker rmi $(docker images -q)

		read -n 1 -s -r -p 'Press any key to continue...'
		echo
	fi
}

installSamba() {
	sudo apt -y install samba
	sudo rsync -a /home/user/dev-vm-linux/etc/samba/smb.conf /etc/samba/
	echo -e "user\nuser" | sudo smbpasswd -s -a user
	sudo service smbd restart
}

# NPM - Node Package Manager
installNpm() {
	cd /tmp && wget https://nodejs.org/dist/v8.11.0/node-v8.11.0-linux-x64.tar.xz
	sudo tar xf node-v8.11.0-linux-x64.tar.xz
	cd node-v8.11.0-linux-x64
	sudo cp -r bin /
	sudo cp -r include /
	sudo cp -r lib /
	sudo cp -r share /

	# Update
	sudo npm install -g npm

	# Install Packages
	sudo npm install -g bower grunt-cli
}

# Yarn - Package Manager
installYarn() {
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
	sudo apt update
	sudo apt install -y --no-install-recommends yarn
}

runApportCli() {
	echo '';
	echo 'Send it or cancel with button "c":';
	sudo apport-cli
}

runSystemUpdate() {
	sudo apt update && sudo apt -y dist-upgrade && sudo apt -y autoremove

	sudo npm -g outdated
	sudo npm install -g npm bower grunt-cli
}

runCleanup() {
	sudo chown -R user:user /etc/apache2/sites-available
	sudo chown -R user:user /etc/apache2/sites-enabled
	sudo chown -R user:user /etc/nginx/sites-available
	sudo chown -R user:user /etc/nginx/sites-enabled

	rm -rf /home/user/dev-vm-linux

	sudo rm -rd /var/www/html
	sudo rm /home/user/.mysql_history
	sudo rm /home/user/.bash_history
	sudo rm /home/user/.zsh_history
	sudo rm /root/.mysql_history
	sudo rm /root/.bash_history
	sudo rm /root/.zsh_history
}

menu() {
	echo ''
	echo '1) Install requirements'
	echo '2) runPart2'
	echo '3) runPart3'
	echo '0) Exit'
	read -p 'Enter your choice: ' choice

	case "$choice" in
		'1')
			runInstallRequirements
		;;
		'2')
			copyFiles
			configureGrub
			configureBash
			installZsh
			installApache2
			installNginx
		;;
		'3')
			installPhpBrew
			installPhpBrewRequirements
			phpBrewBuild
			phpBrewConfigure
		;;
		'4')
			installMySQL
			installFakeMail
			installMailCatcher
			installComposer
			installWebsite
		;;
		'5')
			installDocker
			installDockerCompose
			runDockerTest
		;;
		'6')
			installSamba
			installNpm
			installYarn
		;;
		'8')
			runApportCli
			runSystemUpdate
			runCleanup
		;;
		'9')
			rebootRequiredForce '-'
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
fi
menu
