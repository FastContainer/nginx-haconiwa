#!/bin/bash

# Diff
# - /provision/hacos/postfix.haco
#     ENV['RELAY']
# - /provision/containers/iptables.rules
#     WARP DNAT
# - /provision/containers/script.sh
#     WARP installation

# Do
# vagrant up mxtarpit && vagrant up recipient && vagrant up sender && vagrant up monolith && vagrant up containers
# or
# vagrant up mxtarpit && vagrant up recipient && vagrant up sender && vagrant up containers
# vagrant ssh sender -- "playback -c bulk > /vagrant/experiment/playback.log"

vagrant ssh mxtarpit -- "sudo cp /var/log/syslog /vagrant/experiment/mxtarpit.syslog"
vagrant ssh recipient -- "sudo cp /var/log/syslog /vagrant/experiment/recipient.syslog;\
  sudo cp /var/log/mail.log /vagrant/experiment/recipient.mail.log;\
  sudo cp /var/spool/mail/root /vagrant/experiment/recipient.mail"
vagrant ssh containers -- "sudo cp /var/log/syslog /vagrant/experiment/containers.syslog;\
  sudo cp /var/log/nginx/error.log /vagrant/experiment/containers.nginx.error.log;\
  sudo cp /var/log/nginx/haconiwa.log /vagrant/experiment/containers.nginx.haconiwa.log;\
  sudo cp /var/lib/haconiwa/rootfs/postfix-10-1-100-32/var/log/syslog /vagrant/experiment/container-1.syslog;\
  sudo cp /var/lib/haconiwa/rootfs/postfix-10-1-100-32/var/log/haconiwa.out /vagrant/experiment/container-1.haconiwa.out;\
  sudo cp /var/lib/haconiwa/rootfs/postfix-10-1-100-33/var/log/syslog /vagrant/experiment/container-2.syslog;\
  sudo cp /var/lib/haconiwa/rootfs/postfix-10-1-100-33/var/log/haconiwa.out /vagrant/experiment/container-2.haconiwa.out;\
  sudo cp /var/lib/haconiwa/rootfs/postfix-10-1-100-33/var/log/haconiwa.err /vagrant/experiment/container-2.haconiwa.err;\
  sudo apt install tree;
  sudo tree /var/lib/haconiwa/rootfs/postfix-10-1-100-32/var/spool/postfix > /vagrant/experiment/container-1.tree;\
  sudo tree /var/lib/haconiwa/rootfs/postfix-10-1-100-33/var/spool/postfix > /vagrant/experiment/container-2.tree"

vagrant ssh monolith -- "sudo cp /var/log/syslog /vagrant/experiment/relay.syslog;\
  sudo cp /var/log/mail.log /vagrant/experiment/relay.mail.log;\
  sudo postqueue -p > /vagrant/experiment/relay.postqueue"
