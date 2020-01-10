#!/bin/bash

for i in `seq 2 201`; do
  env IP=10.1.1.${i} \
      ID=postfix-10-1-1-${i} \
      DOMAIN=container1-${i}.test \
      PORT=25 \
      PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    /usr/bin/haconiwa start /var/lib/haconiwa/hacos/postfix-standalone.haco
done

for i in `seq 2 201`; do
  env IP=10.1.2.${i} \
      ID=postfix-10-1-2-${i} \
      DOMAIN=container2-${i}.test \
      PORT=25 \
      PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    /usr/bin/haconiwa start /var/lib/haconiwa/hacos/postfix-standalone.haco
done

for i in `seq 2 201`; do
  env IP=10.1.3.${i} \
      ID=postfix-10-1-3-${i} \
      DOMAIN=container3-${i}.test \
      PORT=25 \
      PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    /usr/bin/haconiwa start /var/lib/haconiwa/hacos/postfix-standalone.haco
done

for i in `seq 2 201`; do
  env IP=10.1.4.${i} \
      ID=postfix-10-1-4-${i} \
      DOMAIN=container4-${i}.test \
      PORT=25 \
      PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    /usr/bin/haconiwa start /var/lib/haconiwa/hacos/postfix-standalone.haco
done
