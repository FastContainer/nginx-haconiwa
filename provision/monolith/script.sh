#!/bin/bash -e

apt upgrade -y
apt install -y bridge-utils openssl curl dstat
locale-gen ja_JP.UTF-8

# install nginx
nginx_ver=1.13.12
cp /data/dist/nginx-${nginx_ver}.tar.gz /usr/local/src/nginx.tar.gz
tar xf /usr/local/src/nginx.tar.gz -C /usr/local/
test -d /etc/nginx || ln -s /usr/local/nginx-${nginx_ver}/conf /etc/nginx
test -x /usr/sbin/nginx || ln -s /usr/local/nginx-${nginx_ver}/sbin/nginx /usr/sbin/nginx
test -d /var/log/nginx || ln -s /usr/local/nginx-${nginx_ver}/logs /var/log/nginx
id nginx >/dev/null 2>&1 || useradd -d /var/www -s /bin/false nginx

test -f /etc/systemd/system/nginx.service || \
  cp /data/monolith/nginx.service /etc/systemd/system/nginx.service && systemctl daemon-reload
rm -rf /etc/nginx/nginx.conf && \
  ln -s /data/monolith/nginx.conf /etc/nginx/nginx.conf

systemctl enable nginx && systemctl start nginx

postconf -e default_process_limit=10000
postconf -e smtpd_client_connection_count_limit=10000

systemctl restart postfix

test -f /etc/systemd/system/dstat.service || \
  cp /data/monolith/dstat.service /etc/systemd/system/dstat.service && systemctl daemon-reload

systemctl enable dstat && systemctl start dstat
