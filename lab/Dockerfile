FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    vsftpd \
    apache2 \
    snmpd \
    samba \
    redis-server \
    default-mysql-server \
    procps \
    iproute2 \
    net-tools \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
COPY vsftpd.conf /etc/vsftpd.conf
COPY snmpd.conf /etc/snmp/snmpd.conf
COPY smb.conf /etc/samba/smb.conf
COPY index.html /var/www/html/index.html
COPY html/flag.txt /var/www/html/flag.txt
COPY content/ftp/welcome.txt /srv/ftp/welcome.txt
COPY content/ftp/flag.txt /srv/ftp/flag.txt
COPY content/samba/public/readme.txt /srv/samba/public/readme.txt
COPY mysql_setup.sql /mysql_setup.sql
COPY redis_flag.txt /redis_flag.txt
RUN chmod +x /start.sh \
    && mkdir -p /run/mysqld /var/run/sshd /srv/ftp /srv/samba/public /var/lib/mysql /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
     

EXPOSE 21 80 139 445 161/udp 3306 6379

CMD ["/start.sh"]
