FROM buildpack-deps:xenial

ENV NGINX_VERSION 1.13.12
ENV OPENSSL_VERSION 1.0.2l
ENV YAML_VERSION 0.2.1

RUN apt-get -qq update
RUN apt-get -qq install build-essential bison libpcre3-dev libpcre++-dev debhelper \
                        flex gcc make automake autoconf libtool git libreadline6-dev \
                        zlib1g-dev libncurses5-dev libssl-dev rake libpam0g-dev \
                        autotools-dev cgroup-lite git
RUN git clone https://github.com/vozlt/nginx-module-vts
RUN git clone https://github.com/matsumotory/ngx_mruby
RUN wget http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz &&\
    tar zxf openssl-$OPENSSL_VERSION.tar.gz
RUN wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz &&\
    tar zxf nginx-$NGINX_VERSION.tar.gz
RUN wget https://pyyaml.org/download/libyaml/yaml-$YAML_VERSION.tar.gz && \
    tar zxf yaml-$YAML_VERSION.tar.gz && \
    cd yaml-$YAML_VERSION && ./configure && make && make install

ADD build_config.rb /ngx_mruby/build_config.rb
ADD entry.sh /entry.sh
RUN chmod +x /entry.sh

CMD ["/entry.sh"]
