#!/bin/bash -e

export DEBIAN_FRONTEND=noninteractive

grep 192.168.30 /etc/hosts >/dev/null || cat /tmp/hosts >> /etc/hosts

apt update -y
apt install -y postfix curl
locale-gen ja_JP.UTF-8

# netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) all --non-interactive
