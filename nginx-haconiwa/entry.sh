#!/bin/bash -xe

prefix=/usr/local/nginx-$NGINX_VERSION
cd /ngx_mruby

./configure \
  --with-ngx-src-root=/nginx-$NGINX_VERSION \
  --with-ngx-config-opt="--with-http_v2_module \
                         --with-http_ssl_module \
                         --with-stream --with-debug \
                         --add-module=/nginx-module-vts \
                         --with-http_stub_status_module \
                         --without-stream_access_module \
                         --prefix=$prefix" \
  --with-openssl-src=/openssl-$OPENSSL_VERSION

make && make install

cd /usr/local
tar -zcvf nginx-$NGINX_VERSION.tar.gz nginx-$NGINX_VERSION
mv nginx-$NGINX_VERSION.tar.gz /builds
