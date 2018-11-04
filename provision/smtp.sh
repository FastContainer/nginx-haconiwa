#!/bin/bash -e

export DEBIAN_FRONTEND=noninteractive

grep 192.168.30 /etc/hosts >/dev/null || cat /tmp/hosts >> /etc/hosts

apt update -y
apt install -y postfix curl
locale-gen ja_JP.UTF-8

postconf -e myhostname="$(hostname)"
postconf -e mynetworks='127.0.0.0/8 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8'
postconf -e smtp_host_lookup='dns native'

systemctl restart postfix

# netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) all --non-interactive
