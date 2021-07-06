#!/bin/bash

if [ "$maildomain" == "" ]; then
  maildomain="example.test"
fi

postconf -e myhostname="$maildomain"
postconf -F '*/*/chroot = n'

# allow private network
postconf -e mynetworks='127.0.0.0/8 192.168.0.0/16 172.16.0.0/12 10.0.0.0/8'
# lookup hosts
postconf -e smtp_host_lookup='native'
postconf -e smtp_dns_support_level='disabled'

if [ "$bench" == "true" ]; then
  # for smtp-sink
  postconf -e relayhost='127.0.0.1:8025'
  smtp-sink -R /root -u root -d sink/%Y%m%d%H/%M. 127.0.0.1:8025 5 &
fi

if [ "$relayhost" != "" ]; then
  # relay
  postconf -e relayhost="$relayhost"
fi

if [ ! -f /var/log/mail.log ]; then
  touch /var/log/mail.log
fi

service rsyslog start
service postfix start

trap "echo got sig-term to exit; exit 0" TERM
while :
do
  sleep 1
done
