#!/bin/bash

PREFIX="6th"
PROXY="$PREFIX/proxy"
RELAY="$PREFIX/relay"

# Proxy
grep container-1 $PROXY/playback.log | awk -v 'OFS= ' '{print $1,$2,$3}' | \
  xargs -IXXX gdate --date="XXX" +"%s" | \
  awk '{print "10, "$1}' > $PREFIX/proxy-sent-to-recipient.csv

grep container-2 $PROXY/playback.log | awk -v 'OFS= ' '{print $1,$2,$3}' | \
  xargs -IXXX gdate --date="XXX" +"%s" | \
  awk '{print "10, "$1}' > $PREFIX/proxy-sent-to-mxtarpit.csv

grep delivered $PROXY/recipient.mail.log | awk -v 'OFS= ' '{print $1,$2,$3}' | \
  xargs -IXXX gdate --date="XXX" +"%s" | sort | uniq -c | \
  awk -v 'OFS=,' '{print $1, $2}' > $PREFIX/proxy-received.csv

# Relay
grep container-1 $RELAY/playback.log | awk -v 'OFS= ' '{print $1,$2,$3}' | \
  xargs -IXXX gdate --date="XXX" +"%s" | \
  awk '{print "10, "$1}' > $PREFIX/relay-sent-to-recipient.csv

grep container-2 $RELAY/playback.log | awk -v 'OFS= ' '{print $1,$2,$3}' | \
  xargs -IXXX gdate --date="XXX" +"%s" | \
  awk '{print "10, "$1}' > $PREFIX/relay-sent-to-mxtarpit.csv

grep delivered $RELAY/recipient.mail.log | awk -v 'OFS= ' '{print $1,$2,$3}' | \
  xargs -IXXX gdate --date="XXX" +"%s" | sort | uniq -c | \
  awk -v 'OFS=,' '{print $1, $2}' > $PREFIX/relay-received.csv
