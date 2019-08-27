#!/bin/bash

NAME=postfix
IP=10.0.5.88
PORT=19999

ID=$NAME-sandbox
ROOTFS=/var/lib/haconiwa/rootfs/$ID
IMAGE=/var/lib/haconiwa/images/$NAME.image.tar
HACOFILE=/var/lib/haconiwa/hacos/$NAME.haco
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if [ ! -d $ROOTFS ]; then
  /bin/mkdir -m 755 -p $ROOTFS
  /bin/tar xfp $IMAGE -C $ROOTFS
fi

/bin/echo "127.0.0.1 localhost $ID" >> $ROOTFS/etc/hosts &&
  /bin/cat /data/hosts >> $ROOTFS/etc/hosts

/bin/env IP=$IP PORT=$PORT ID=$ID PATH=$PATH /usr/bin/haconiwa start $HACOFILE
