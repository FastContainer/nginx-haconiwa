#!/bin/bash

env IP=10.1.1.9 \
    ID=postfix-10-1-1-9 \
    DOMAIN=container-9.test \
    PORT=25 \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
  /usr/bin/haconiwa start /var/lib/haconiwa/hacos/postfix-standalone.haco
