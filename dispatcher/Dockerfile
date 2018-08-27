FROM buildpack-deps:xenial

ENV CRUBY_VERSION 2.5.1
ENV HACONIWA_VERSION 160a1807c3f7daef17d2933acf7f337bf91ae4bb
# https://github.com/haconiwa/haconiwa/blob/master/mruby_version.lock
ENV MRUBY_VERSION 35be8b252495d92ca811d76996f03c470ee33380

RUN apt -y update
RUN apt -y install build-essential bison libpcre3-dev libpcre++-dev debhelper \
                   flex gcc make automake autoconf libtool git libreadline6-dev \
                   zlib1g-dev libncurses5-dev libssl-dev rake libpam0g-dev \
                   autotools-dev cgroup-lite git

RUN mkdir -p /opt/ruby-$CRUBY_VERSION/ && \
    curl -s https://s3-external-1.amazonaws.com/heroku-buildpack-ruby/cedar-14/ruby-$CRUBY_VERSION.tgz | tar xzC /opt/ruby-$CRUBY_VERSION/
ENV PATH /opt/ruby-$CRUBY_VERSION/bin:$PATH
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/

RUN mkdir /builds
WORKDIR /builds

CMD ["rake", "compile"]
