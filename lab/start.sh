#!/bin/bash
set -e

# mysql / mariadb
mkdir -p /run/mysqld
mkdir -p /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
  mysql_install_db --user=mysql --ldata=/var/lib/mysql || mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

service mariadb start || service mysql start

mysql -uroot < /mysql_setup.sql || true

# redis
service redis-server start || true
redis-cli SET workshop:flag "$(cat /redis_flag.txt)" >/dev/null 2>&1 || true

# apache
service apache2 start || true

# snmp
service snmpd start || true

# samba
mkdir -p /srv/samba/public
chown -R nobody:nogroup /srv/samba/public || true
service smbd start || true
service nmbd start || true

# ftp
mkdir -p /srv/ftp
chown -R ftp:ftp /srv/ftp || true
/usr/sbin/vsftpd /etc/vsftpd.conf &

echo "[+] Enumeration lab target started."
echo "[+] Scan target: 172.28.21.12"

tail -f /dev/null
