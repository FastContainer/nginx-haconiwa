FROM buildpack-deps:xenial

ENV NGINX_VERSION 1.13.12
ENV OPENSSL_VERSION 1.0.2l
ENV YAML_VERSION 0.2.1
ENV NGX_VTS_REV 46d85558e344dfe2b078ce757fd36c69a1ec2dd3
ENV NGX_MRUBY_REV 28682daa710baeb30f927d449ad22b56338595d2

RUN apt -y update
RUN apt -y install build-essential bison libpcre3-dev libpcre++-dev debhelper \
                   flex gcc make automake autoconf libtool git libreadline6-dev \
                   zlib1g-dev libncurses5-dev libssl-dev rake libpam0g-dev \
                   autotools-dev cgroup-lite git
RUN git clone --depth=100 https://github.com/vozlt/nginx-module-vts && \
    cd nginx-module-vts && git checkout $NGX_VTS_REV
RUN git clone --depth=100 https://github.com/matsumotory/ngx_mruby && \
    cd ngx_mruby && git checkout $NGX_MRUBY_REV
RUN wget http://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz && \
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
