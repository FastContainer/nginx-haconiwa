#!/bin/bash

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

service rsyslog start
service postfix start
sleep 10
/usr/sbin/netdata -D

# https://stackoverflow.com/questions/9256644/identifying-received-signal-name-in-bash/9256709#9256709
trap_with_arg() {
  func="$1" ; shift
  for sig ; do
    trap "$func $sig" "$sig"
  done
}

func_trap() {
  echo Trapped: $1
}

trap_with_arg func_trap INT TERM EXIT

tail -f /var/log/mail.log
