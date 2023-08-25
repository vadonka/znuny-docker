#!/bin/sh

echo -n "Starting rsyslog..."
systemctl start rsyslog
echo "Done."

if [ "$NO_START_ZNUNY" != "1" ]; then
    echo -n "Starting MariaDB and httpd service..."
    echo -n "mariadb..."
    systemctl start mariadb
    echo -n "httpd..."
    systemctl start httpd
    echo "Done."
    echo "Starting Znuny cron:"
    su -c '~/bin/Cron.sh start' znuny
    echo "Starting Znuny daemon:"
    su -c '~/bin/znuny.Daemon.pl start' znuny
else
    echo "MariaDB and httpd not started."
fi

tail -f /var/log/messages
