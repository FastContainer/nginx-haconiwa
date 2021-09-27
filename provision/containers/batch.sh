#!/bin/bash -x

sysctl -w net.core.somaxconn=4096
ulimit -n 100000

# expand postfix image
postfix_rootfs_path=/var/lib/haconiwa/rootfs/shared/postfix
postfix_image_path=/var/lib/haconiwa/images/postfix.image.tar
postfix_workdir_path=/var/lib/haconiwa/images/postfix-workdir.tar.gz
test -d ${postfix_rootfs_path} || mkdir -m 755 -p ${postfix_rootfs_path}
test -n "`ls ${postfix_rootfs_path}`" || tar xfp ${postfix_image_path} -C ${postfix_rootfs_path}
for i in `seq 2 201`; do
  path=/var/lib/haconiwa/rootfs/postfix-10-1-1-${i}
  if [ ! -d $path ]; then
    mkdir -m 755 -p ${path} && tar xzfp ${postfix_workdir_path} -C ${path}
  fi
  sleep 1
done
for i in `seq 2 201`; do
  path=/var/lib/haconiwa/rootfs/postfix-10-1-2-${i}
  if [ ! -d $path ]; then
    mkdir -m 755 -p ${path} && tar xzfp ${postfix_workdir_path} -C ${path}
  fi
  sleep 1
done
for i in `seq 2 201`; do
  path=/var/lib/haconiwa/rootfs/postfix-10-1-3-${i}
  if [ ! -d $path ]; then
    mkdir -m 755 -p ${path} && tar xzfp ${postfix_workdir_path} -C ${path}
  fi
  sleep 1
done
for i in `seq 2 201`; do
  path=/var/lib/haconiwa/rootfs/postfix-10-1-4-${i}
  if [ ! -d $path ]; then
    mkdir -m 755 -p ${path} && tar xzfp ${postfix_workdir_path} -C ${path}
  fi
  sleep 1
done
for i in `seq 2 201`; do
  path=/var/lib/haconiwa/rootfs/postfix-10-1-5-${i}
  if [ ! -d $path ]; then
    mkdir -m 755 -p ${path} && tar xzfp ${postfix_workdir_path} -C ${path}
  fi
  sleep 1
done

# start postfix
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
