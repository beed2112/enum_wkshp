#!/bin/bash
set -e

ENUM_TARGET_IP="${ENUM_TARGET_IP:-172.28.21.12}"
WORDPRESS_URL="${WORDPRESS_URL:-http://${ENUM_TARGET_IP}}"

MYSQL_SSL_DIR=/etc/mysql/ssl
MYSQL_SSL_CA_KEY="$MYSQL_SSL_DIR/ca-key.pem"
MYSQL_SSL_CA_CERT="$MYSQL_SSL_DIR/ca-cert.pem"
MYSQL_SSL_SERVER_KEY="$MYSQL_SSL_DIR/server-key.pem"
MYSQL_SSL_SERVER_CSR="$MYSQL_SSL_DIR/server.csr"
MYSQL_SSL_SERVER_CERT="$MYSQL_SSL_DIR/server-cert.pem"
MYSQL_SSL_OPENSSL_CNF="$MYSQL_SSL_DIR/server-cert.cnf"

# mysql / mariadb
# mysql / mariadb
mkdir -p /run/mysqld
mkdir -p /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

mkdir -p "$MYSQL_SSL_DIR"

if [ ! -f "$MYSQL_SSL_SERVER_CERT" ] || [ ! -f "$MYSQL_SSL_SERVER_KEY" ] || [ ! -f "$MYSQL_SSL_CA_CERT" ]; then
  cat > "$MYSQL_SSL_OPENSSL_CNF" <<'EOF'
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[ dn ]
CN = enumlab-target

[ req_ext ]
subjectAltName = @alt_names
extendedKeyUsage = serverAuth

[ alt_names ]
DNS.1 = enumlab-target
IP.1 = 172.28.21.12
EOF

  openssl genrsa -out "$MYSQL_SSL_CA_KEY" 2048
  openssl req -x509 -new -nodes -key "$MYSQL_SSL_CA_KEY" -sha256 -days 3650 \
    -out "$MYSQL_SSL_CA_CERT" -subj "/CN=enumlab-mysql-ca"
  openssl genrsa -out "$MYSQL_SSL_SERVER_KEY" 2048
  openssl req -new -key "$MYSQL_SSL_SERVER_KEY" -out "$MYSQL_SSL_SERVER_CSR" \
    -config "$MYSQL_SSL_OPENSSL_CNF"
  openssl x509 -req -in "$MYSQL_SSL_SERVER_CSR" -CA "$MYSQL_SSL_CA_CERT" -CAkey "$MYSQL_SSL_CA_KEY" \
    -CAcreateserial -out "$MYSQL_SSL_SERVER_CERT" -days 3650 -sha256 \
    -extensions req_ext -extfile "$MYSQL_SSL_OPENSSL_CNF"
fi

chown -R mysql:mysql "$MYSQL_SSL_DIR"
chmod 600 "$MYSQL_SSL_CA_KEY" "$MYSQL_SSL_SERVER_KEY"
chmod 644 "$MYSQL_SSL_CA_CERT" "$MYSQL_SSL_SERVER_CERT"
rm -f "$MYSQL_SSL_SERVER_CSR" "$MYSQL_SSL_DIR/ca-cert.srl"

if [ ! -d /var/lib/mysql/mysql ]; then
  mysql_install_db --user=mysql --ldata=/var/lib/mysql || mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

service mariadb start || service mysql start || true
sleep 5

mysqladmin ping -uroot || true
mysql -uroot < /mysql_setup.sql || true

if ! mysql -uroot wordpress -Nse "SHOW TABLES LIKE 'wp_options'" | grep -q wp_options; then
  /usr/local/bin/wp core install \
    --path=/var/www/vulnerablewordpress \
    --url="$WORDPRESS_URL" \
    --title='Enumeration Workshop Blog' \
    --admin_user=admin \
    --admin_password=admin \
    --admin_email=admin@enumlab.local \
    --skip-email \
    --allow-root || true
fi

# redis
/usr/bin/redis-server /etc/redis/redis.conf &
for i in $(seq 1 30); do
  if redis-cli -h 127.0.0.1 ping >/dev/null 2>&1; then
    redis-cli -h 127.0.0.1 SET workshop:flag "$(cat /redis_flag.txt)" >/dev/null 2>&1 || true
    break
  fi
  sleep 1
done

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

# tftp
mkdir -p /srv/tftp
chown -R nobody:nogroup /srv/tftp || true
chmod 755 /srv/tftp

[ -f /srv/tftp/welcome.txt ] && chmod 444 /srv/tftp/welcome.txt
[ -f /srv/tftp/flag.txt ] && chmod 444 /srv/tftp/flag.txt

/usr/sbin/in.tftpd --foreground --listen --address 0.0.0.0:69 --secure /srv/tftp &

echo "[+] Enumeration lab target started."
echo "[+] Scan target: 172.28.21.12"

tail -f /dev/null
