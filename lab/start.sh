#!/bin/bash
set -e

# mysql / mariadb
# mysql / mariadb
mkdir -p /run/mysqld
mkdir -p /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
  mysql_install_db --user=mysql --ldata=/var/lib/mysql || mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

service mariadb start || service mysql start || true
sleep 5

mysqladmin --ssl=0 ping -uroot || true
mysql --ssl=0 -uroot < /mysql_setup.sql || true

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
# ftp
mkdir -p /srv/ftp
chown root:root /srv/ftp
chmod 555 /srv/ftp

[ -f /srv/ftp/welcome.txt ] && chown root:root /srv/ftp/welcome.txt && chmod 444 /srv/ftp/welcome.txt
[ -f /srv/ftp/flag.txt ] && chown root:root /srv/ftp/flag.txt && chmod 444 /srv/ftp/flag.txt

/usr/sbin/vsftpd /etc/vsftpd.conf &

echo "[+] Enumeration lab target started."
echo "[+] Scan target: 172.28.21.12"

tail -f /dev/null
