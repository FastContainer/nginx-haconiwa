#!/bin/bash -e

apt upgrade -y
apt install -y bridge-utils openssl curl
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
  cp /data/postfix/nginx.service /etc/systemd/system/nginx.service && systemctl daemon-reload
rm -rf /etc/nginx/nginx.conf && \
  ln -s /data/postfix/nginx.conf /etc/nginx/nginx.conf
rm -rf /etc/nginx/conf.d && \
  ln -s /data/postfix/conf.d /etc/nginx/conf.d

systemctl enable nginx && systemctl start nginx

# install postfix
export DEBIAN_FRONTEND=noninteractive

apt update -y
apt install -y postfix curl
locale-gen ja_JP.UTF-8

postconf -e myhostname="$(hostname)"
postconf -e mynetworks='127.0.0.0/8 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8'
postconf -e smtp_host_lookup='native'
postconf -e smtp_dns_support_level='disabled'
postconf -e default_process_limit='5'

systemctl restart postfix
