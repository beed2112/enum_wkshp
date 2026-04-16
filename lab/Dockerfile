FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV ENUM_TARGET_IP=172.28.21.12 \
    WORDPRESS_DB_NAME=wordpress \
    WORDPRESS_DB_USER=wordpress \
    WORDPRESS_DB_PASSWORD=wordpress \
    WORDPRESS_DB_HOST=127.0.0.1 \
    WORDPRESS_URL=http://172.28.21.12

RUN apt-get update && apt-get install -y \
    vsftpd \
    apache2 \
    snmpd \
    samba \
    redis-server \
    tftpd-hpa \
    default-mysql-server \
    openssl \
    php \
    php-cli \
    php-mysql \
    php-gd \
    libapache2-mod-php \
    unzip \
    procps \
    iproute2 \
    net-tools \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
COPY vsftpd.conf /etc/vsftpd.conf
COPY snmpd.conf /etc/snmp/snmpd.conf
COPY smb.conf /etc/samba/smb.conf
COPY enumlab.cnf /etc/mysql/mariadb.conf.d/60-enumlab.cnf
COPY redis-enumlab.conf /etc/redis/redis.conf
COPY apache/ports.conf /etc/apache2/ports.conf
COPY apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY apache/landing-8080.conf /etc/apache2/sites-available/landing-8080.conf
COPY apache/header.conf /etc/apache2/conf-enabled/header.conf
COPY index.html /var/www/html/index.html
COPY html/flag.txt /var/www/html/flag.txt
COPY content/ftp/welcome.txt /srv/ftp/welcome.txt
COPY content/ftp/flag.txt /srv/ftp/flag.txt
COPY content/tftp/welcome.txt /srv/tftp/welcome.txt
COPY content/tftp/flag.txt /srv/tftp/flag.txt
COPY content/samba/public/readme.txt /srv/samba/public/readme.txt
COPY content/samba/public/flag.txt /srv/samba/public/flag.txt
COPY mysql_setup.sql /mysql_setup.sql
COPY redis_flag.txt /redis_flag.txt

RUN set -eux; \
    mkdir -p /var/www/vulnerablewordpress /var/www/vulnerablewordpress/wp-content; \
    curl -fsSL https://raw.githubusercontent.com/wpscanteam/VulnerableWordpress/master/latest.tar.gz -o /tmp/vulnerablewordpress.tar.gz; \
    tar xzf /tmp/vulnerablewordpress.tar.gz -C /tmp; \
    mv /tmp/wordpress/* /var/www/vulnerablewordpress/; \
    rm -rf /tmp/wordpress /tmp/vulnerablewordpress.tar.gz; \
    cp /var/www/vulnerablewordpress/wp-config-sample.php /var/www/vulnerablewordpress/wp-config.php; \
    sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/vulnerablewordpress/wp-config.php; \
    sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/vulnerablewordpress/wp-config.php; \
    sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" /var/www/vulnerablewordpress/wp-config.php; \
    sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/vulnerablewordpress/wp-config.php; \
    sed -i "s/put your unique phrase here/enum-wkshp-static-salt/g" /var/www/vulnerablewordpress/wp-config.php; \
    sed -i "/^define('WP_DEBUG', false);/a define('WP_HOME', '${WORDPRESS_URL}');\ndefine('WP_SITEURL', '${WORDPRESS_URL}');" /var/www/vulnerablewordpress/wp-config.php; \
    sed -i "/^require_once(ABSPATH \\. 'wp-settings.php');/i if (!function_exists('get_magic_quotes_gpc')) { function get_magic_quotes_gpc() { return false; } }" /var/www/vulnerablewordpress/wp-config.php; \
    curl -fsSL https://raw.githubusercontent.com/wpscanteam/VulnerableWordpress/master/files/robots.txt -o /var/www/vulnerablewordpress/robots.txt; \
    curl -fsSL https://raw.githubusercontent.com/wpscanteam/VulnerableWordpress/master/files/debug.log -o /var/www/vulnerablewordpress/wp-content/debug.log; \
    curl -fsSL https://raw.githubusercontent.com/wpscanteam/VulnerableWordpress/master/files/searchreplacedb2.php -o /var/www/vulnerablewordpress/searchreplacedb2.php; \
    cp /var/www/html/flag.txt /var/www/vulnerablewordpress/flag.txt; \
    for f in wp-config.php~ wp-config.php.save wp-config.old wp-config.txt; do cp /var/www/vulnerablewordpress/wp-config.php "/var/www/vulnerablewordpress/$f"; done; \
    curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp; \
    chmod +x /usr/local/bin/wp; \
    a2enmod headers php*;

RUN chmod +x /start.sh \
    && mkdir -p /run/mysqld /var/lib/mysql /srv/ftp /srv/tftp /srv/samba/public /var/www/html /var/www/vulnerablewordpress \
    && chown -R www-data:www-data /var/www/html /var/www/vulnerablewordpress

RUN a2ensite landing-8080

EXPOSE 21 69/udp 80 8080 139 445 161/udp 3306 6379

CMD ["/start.sh"]