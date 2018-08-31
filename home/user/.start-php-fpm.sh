#!/usr/bin/env bash

function startPhpFpm {
	_PHP_VERSION=php-${1}
	if [ -f ${PHPBREW_ROOT}/php/${_PHP_VERSION}/bin/php ]; then
		mkdir -p ${PHPBREW_ROOT}/php/${_PHP_VERSION}/var/run
		PHPFPM_BIN=${PHPBREW_ROOT}/php/${_PHP_VERSION}/sbin/php-fpm
		PHPFPM_PIDFILE=${PHPBREW_ROOT}/php/${_PHP_VERSION}/var/run/php-fpm.pid

		${PHPFPM_BIN} --php-ini ${PHPBREW_ROOT}/php/${_PHP_VERSION}/etc/php.ini \
			--fpm-config ${PHPBREW_ROOT}/php/${_PHP_VERSION}/etc/php-fpm.conf \
			--pid ${PHPFPM_PIDFILE}
	fi
}

if [ -f /home/user/.phpbrew/bashrc ]; then
	source /home/user/.phpbrew/bashrc
	if [[ $(lsb_release -rs) == '16.04' ]]; then
		startPhpFpm 5.4.45
		startPhpFpm 5.5.38
		startPhpFpm 5.6.36
	fi;
	startPhpFpm 7.0.30
	startPhpFpm 7.1.17
	startPhpFpm 7.2.5
fi
