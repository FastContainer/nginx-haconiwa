#!/bin/bash -e

export DEBIAN_FRONTEND=noninteractive

apt update -y
apt install -y postfix curl
locale-gen ja_JP.UTF-8

# netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) all --non-interactive
