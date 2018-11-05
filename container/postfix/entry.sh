#!/bin/bash

postconf -e myhostname="$maildomain"
postconf -F '*/*/chroot = n'

# allow private network
postconf -e mynetworks='127.0.0.0/8 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8'
# lookup hosts
postconf -e smtp_host_lookup='dns native'

if [ "$bench" == "true" ]; then
  # for smtp-sink
  postconf -e relayhost='127.0.0.1:8025'
  smtp-sink -R /root -u root -d sink/%Y%m%d%H/%M. 127.0.0.1:8025 5 &
fi

service rsyslog start
service postfix restart
sleep 20
tail -f /var/log/mail.log
