#!/bin/bash -e

export GOLANG_VERSION=1.12.6
export GOPATH=/go

apt-get update
apt-get install -y --no-install-recommends g++ gcc libc6-dev make pkg-config
wget -O go.tgz "https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz"
tar -C /usr/local -xzf go.tgz
rm go.tgz

mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
mkdir -p "$GOPATH/src/github.com/FastContainer"
git clone https://github.com/FastContainer/playback.git "$GOPATH/src/github.com/FastContainer/playback"

ln -s /usr/local/go/bin/go /usr/local/bin/go
cd /go/src/github.com/FastContainer/playback
export GO111MODULE=on
make
mv ./playback /usr/local/bin/playback
