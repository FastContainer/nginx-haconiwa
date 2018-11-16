#!/bin/bash

FROM='root@smtp-client'

function multi_account() {
  smtp-source -s 1000 -m 10000 -c -N -f $FROM -t 'ma@smtp-tarpit' -S "multi account: $(LANG=C date)" smtp-server:25 &
  smtp-source -s 1 -m 1 -c -f $FROM -S 'test mail by multi account' -t 'root@smtp-rcpt' smtp-server:25 &
}

function cluster_account() {
  smtp-source -s 1000 -m 10000 -c -N -f $FROM -t 'ca@smtp-tarpit' -S "cluster account: $(LANG=C date)" containers:58025 &
  smtp-source -s 1 -m 1 -c -f $FROM -S 'test mail by cluster account' -t 'root@smtp-rcpt' containers:58026 &
}

multi_account
cluster_account
