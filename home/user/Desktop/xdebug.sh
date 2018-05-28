#!/usr/bin/env bash

function xdebugSwitcher {
	title="$(tr '[:lower:]' '[:upper:]' <<< ${1:0:1})${1:1}"
	if [ -f /home/user/.phpbrew/php/php-${2}/bin/php ]; then
		echo ${title} xDebug on PHP ${2}
		phpbrew use ${2}
		phpbrew extension ${1} xdebug
		phpbrew fpm restart
	else
		echo [Warning] PHP ${2} not found
	fi
	echo
}

if [ -f /home/user/.phpbrew/bashrc ]; then
	source /home/user/.phpbrew/bashrc
	read -p 'Enable xDebug? [y/N] ' -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		xdebugSwitcher 'enable' '5.4.45'
		xdebugSwitcher 'enable' '5.5.38'
		xdebugSwitcher 'enable' '5.6.36'
		xdebugSwitcher 'enable' '7.0.30'
		xdebugSwitcher 'enable' '7.1.17'
		xdebugSwitcher 'enable' '7.2.5'
	else
		xdebugSwitcher 'disable' '5.4.45'
		xdebugSwitcher 'disable' '5.5.38'
		xdebugSwitcher 'disable' '5.6.36'
		xdebugSwitcher 'disable' '7.0.30'
		xdebugSwitcher 'disable' '7.1.17'
		xdebugSwitcher 'disable' '7.2.5'
	fi
else
	echo [Error] PhpBrew not found
fi
