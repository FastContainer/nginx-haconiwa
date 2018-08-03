#!/bin/bash

postconf -e myhostname="$maildomain"
postconf -F '*/*/chroot = n'

# allow private network
postconf -e mynetworks='127.0.0.0/8 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8'

service rsyslog start
service postfix start
sleep 20
tail -f /var/log/mail.log
