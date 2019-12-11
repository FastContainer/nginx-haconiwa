#!/bin/bash -e

nginx_ver=1.13.12
common_name=fastcontainer.example
images=("nginx" "ssh" "postfix")

grep 192.168.30 /etc/hosts >/dev/null || cat /data/hosts >> /etc/hosts

apt upgrade -y
apt install -y bridge-utils openssl curl
locale-gen ja_JP.UTF-8

# install haconiwa
type haconiwa >/dev/null 2>&1 || \
  curl -s https://packagecloud.io/install/repositories/udzura/haconiwa/script.deb.sh | bash && \
  apt install -y haconiwa #'haconiwa=0.9.4-1'

apt-get install -y criu
haconiwa_ver=0.10.4
wget https://github.com/haconiwa/haconiwa/releases/download/v${haconiwa_ver}/haconiwa-v${haconiwa_ver}.x86_64-pc-linux-gnu.tgz
tar xzf haconiwa-v${haconiwa_ver}.x86_64-pc-linux-gnu.tgz
rm -rf /usr/bin/haco*
install hacorb hacoirb haconiwa /usr/bin

# deploy hacofile
test -d /var/log/haconiwa || mkdir -p /var/log/haconiwa
test -d /var/lib/haconiwa/rootfs || mkdir -p /var/lib/haconiwa/rootfs
rm -rf /var/lib/haconiwa/hacos && ln -s /data/hacos /var/lib/haconiwa/hacos
rm -rf /var/lib/haconiwa/images && ln -s /data/dist /var/lib/haconiwa/images

# expand postfix image
postfix_rootfs_path=/var/lib/haconiwa/rootfs/shared/postfix
postfix_image_path=/var/lib/haconiwa/images/postfix.image.tar
postfix_workdir_path=/var/lib/haconiwa/images/postfix-workdir.tar.gz
test -d ${postfix_rootfs_path} || mkdir -m 755 -p ${postfix_rootfs_path}
test -n "`ls ${postfix_rootfs_path}`" || tar xfp ${postfix_image_path} -C ${postfix_rootfs_path}
for i in `seq 2 201`; do
  path=/var/lib/haconiwa/rootfs/postfix-10-1-1-${i}
  if [ ! -d $path ]; then
    mkdir -m 755 -p ${path} && tar xzfp ${postfix_workdir_path} -C ${path}
  fi
  sleep 1
done
for i in `seq 2 201`; do
  path=/var/lib/haconiwa/rootfs/postfix-10-1-2-${i}
  if [ ! -d $path ]; then
    mkdir -m 755 -p ${path} && tar xzfp ${postfix_workdir_path} -C ${path}
  fi
  sleep 1
done
for i in `seq 2 201`; do
  path=/var/lib/haconiwa/rootfs/postfix-10-1-3-${i}
  if [ ! -d $path ]; then
    mkdir -m 755 -p ${path} && tar xzfp ${postfix_workdir_path} -C ${path}
  fi
  sleep 1
done
for i in `seq 2 201`; do
  path=/var/lib/haconiwa/rootfs/postfix-10-1-4-${i}
  if [ ! -d $path ]; then
    mkdir -m 755 -p ${path} && tar xzfp ${postfix_workdir_path} -C ${path}
  fi
  sleep 1
done
for i in `seq 2 201`; do
  path=/var/lib/haconiwa/rootfs/postfix-10-1-5-${i}
  if [ ! -d $path ]; then
    mkdir -m 755 -p ${path} && tar xzfp ${postfix_workdir_path} -C ${path}
  fi
  sleep 1
done

# setup network
brctl show haconiwa0 2>&1 | grep -i "no such device" && \
  haconiwa init --bridge --bridge-ip=10.1.0.1/16
test $(/sbin/sysctl net.ipv4.ip_forward | awk '{print $3}') -eq 0 && \
  /sbin/sysctl -w net.ipv4.ip_forward=1
/sbin/iptables-restore < /data/containers/iptables.rules

# install nginx
cp /data/dist/nginx-${nginx_ver}.tar.gz /usr/local/src/nginx.tar.gz
tar xf /usr/local/src/nginx.tar.gz -C /usr/local/
test -d /etc/nginx || ln -s /usr/local/nginx-${nginx_ver}/conf /etc/nginx
test -x /usr/sbin/nginx || ln -s /usr/local/nginx-${nginx_ver}/sbin/nginx /usr/sbin/nginx
test -d /var/log/nginx || ln -s /usr/local/nginx-${nginx_ver}/logs /var/log/nginx
id nginx >/dev/null 2>&1 || useradd -d /var/www -s /bin/false nginx

test -f /etc/systemd/system/nginx.service || \
  cp /data/containers/nginx/nginx.service /etc/systemd/system/nginx.service && systemctl daemon-reload
rm -rf /etc/nginx/nginx.conf && \
  ln -s /data/containers/nginx/nginx.conf /etc/nginx/nginx.conf
rm -rf /etc/nginx/conf.d && \
  ln -s /data/containers/nginx/conf.d /etc/nginx/conf.d

test -f /etc/nginx/tls.crt || \
  openssl req -x509 -days 365 -newkey rsa:2048 -nodes \
  -out /etc/nginx/tls.crt -keyout /etc/nginx/tls.key \
  -subj "/C=JP/ST=Fukuoka/L=Fukuoka/O=FastContainer/OU=Haconiwa/CN=${common_name}" >/dev/null 2>&1

# add script
rm -rf /usr/local/bin/cleanip && ln -s /data/containers/cleanip /usr/local/bin/cleanip

# dstat daemon
apt-get install -y dstat
test -f /usr/share/dstat/dstat_postfix_proc_count.py || \
  cp /data/containers/dstat_postfix_proc_count.py /usr/share/dstat/dstat_postfix_proc_count.py
test -f /etc/systemd/system/dstat.service || \
  cp /data/containers/dstat.service /etc/systemd/system/dstat.service && systemctl daemon-reload

systemctl enable dstat && systemctl start dstat
systemctl enable nginx && systemctl start nginx
