#!/bin/bash

apt-get update -yy
apt-get install -yy make build-essential libev-dev
locale-gen ja_JP.UTF-8

test -d /var/empty || mkdir /var/empty
test -d /usr/src/mxtarpit || \
  git clone https://github.com/martinh/mxtarpit.git /usr/src/mxtarpit
cd /usr/src/mxtarpit
make linux
mv ./mxtarpit /usr/sbin/mxtarpit
test -f /etc/systemd/system/mxtarpit.service || \
  cp /tmp/mxtarpit.service /etc/systemd/system/mxtarpit.service && systemctl daemon-reload
systemctl start mxtarpit
