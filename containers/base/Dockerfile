FROM buildpack-deps:xenial

ENV HACONIWA_ROOT /var/lib/haconiwa

ADD haconiwa $HACONIWA_ROOT
RUN mkdir /usr/local/libexec && \
    chown www-data:www-data $HACONIWA_ROOT/rootfs/var/log/container && \
    chmod 750 $HACONIWA_ROOT/rootfs/var/log/container

RUN apt -yy update && \
    apt upgrade -yy bash && \
    apt install -yy net-tools bridge-utils iproute2 iputils-ping vim
