#!/bin/sh

echo -n "Starting rsyslog..."
systemctl start rsyslog > /dev/null 2>&1
if [ $? -eq 0 ] || [ $? -eq 1 ]; then
    echo OK
else
    echo FAIL
    exit 1
fi

echo -n "Starting MariaDB..."
systemctl start mariadb > /dev/null 2>&1
if [ $? -eq 0 ] || [ $? -eq 1 ]; then
    echo OK
else
    echo FAIL
    exit 1
fi

if [ "$NO_START_ZNUNY" != "1" ]; then
    echo -n "Starting Httpd service..."
    systemctl start httpd > /dev/null 2>&1
    if [ $? -eq 0 ] || [ $? -eq 1 ]; then
	echo OK
    else
	echo FAIL
	exit 1
    fi

    echo "Fixing Znuny permissions."
    /opt/znuny/bin/otrs.SetPermissions.pl
    echo "Starting Znuny cron:"
    su -c '~/bin/Cron.sh start' znuny
    echo "Starting Znuny daemon:"
    su -c '~/bin/znuny.Daemon.pl start' znuny
else
    echo "MariaDB and httpd not started."
fi

tail -f /var/log/messages
