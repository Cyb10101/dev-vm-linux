#!/usr/bin/env bash
function startPhpFpm {
	if [ -f /home/user/.phpbrew/php/php-${1}/bin/php ]; then
		phpbrew use ${1}
		phpbrew fpm start
	fi
}

if [ -f /home/user/.phpbrew/bashrc ]; then
	source /home/user/.phpbrew/bashrc
	startPhpFpm 5.4.45
	startPhpFpm 5.5.38
	startPhpFpm 5.6.36
	startPhpFpm 7.0.30
	startPhpFpm 7.1.17
	startPhpFpm 7.2.5
fi
