#!/bin/bash -e

export DEBIAN_FRONTEND=noninteractive

grep 192.168.30 /etc/hosts >/dev/null || cat /tmp/hosts >> /etc/hosts

apt update -y
apt install -y postfix curl
locale-gen ja_JP.UTF-8

postconf -e myhostname="$(hostname)"
postconf -e mynetworks='127.0.0.0/8 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8'
postconf -e smtp_host_lookup='native'
postconf -e smtp_dns_support_level='disabled'
postconf -e default_process_limit='5'

systemctl restart postfix
