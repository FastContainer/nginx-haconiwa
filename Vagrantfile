# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/xenial64'

  #config.vm.network 'private_network', ip: '192.168.33.10'
  config.vm.synced_folder './artifacts', '/artifacts'
  config.vm.synced_folder './misc', '/misc'

  %w(80 443).each do |port|
    config.vm.network 'forwarded_port', guest: port, host: "8#{port.rjust(3, '0')}"
  end

  %w(22 25 587 465).each do |port|
    p = "8#{port.rjust(3, '0')}"
    config.vm.network 'forwarded_port', guest: p, host: p
  end

  config.vm.provider 'virtualbox' do |vb|
    #vb.gui = true
    vb.memory = '1024'
  end

  nginx_ver = '1.13.12'
  common_name = 'fastcontainer.local'

  config.vm.provision 'shell', inline: <<-SHELL
    set -e
    apt-get update
    apt-get install -yy bridge-utils openssl curl
    locale-gen ja_JP.UTF-8

    # install haconiwa
    type haconiwa >/dev/null 2>&1 || \
      curl -s https://packagecloud.io/install/repositories/udzura/haconiwa/script.deb.sh | bash && \
      apt-get install -y haconiwa

    # deploy hacofile
    test -d /var/lib/haconiwa || mkdir -p /var/lib/haconiwa
    rm -rf /var/lib/haconiwa/hacos && ln -s /misc/hacos /var/lib/haconiwa/hacos
    test -d /var/lib/haconiwa/rootfs || mkdir -p /var/lib/haconiwa/rootfs

    # deploy nginx container images
    test -d /var/lib/haconiwa/rootfs/nginx || mkdir /var/lib/haconiwa/rootfs/nginx
    tar xfp /artifacts/nginx.*.image.tar.gz -C /var/lib/haconiwa/rootfs/nginx

    # deploy ssh container images
    test -d /var/lib/haconiwa/rootfs/ssh || mkdir /var/lib/haconiwa/rootfs/ssh
    tar xfp /artifacts/ssh.*.image.tar.gz -C /var/lib/haconiwa/rootfs/ssh

    # deploy postfix container images
    test -d /var/lib/haconiwa/rootfs/postfix || mkdir /var/lib/haconiwa/rootfs/postfix
    tar xfp /artifacts/postfix.*.image.tar.gz -C /var/lib/haconiwa/rootfs/postfix

    # setup network
    brctl show haconiwa0 2>&1 | grep -i "no such device" && brctl addbr haconiwa0
    ip addr show haconiwa0 2>&1 | grep "10.0.5.1/24" || \
      ip addr add 10.0.5.1/24 dev haconiwa0 && ip link set dev haconiwa0 up
    test $(/sbin/sysctl net.ipv4.ip_forward | awk '{print $3}') -eq 0 && \
      /sbin/sysctl -w net.ipv4.ip_forward=1
    /sbin/iptables-restore < /misc/iptables.rules

    # install nginx
    cp /artifacts/nginx-#{nginx_ver}-*.tar.gz /usr/local/src/nginx.tar.gz
    tar xf /usr/local/src/nginx.tar.gz -C /usr/local/
    test -d /etc/nginx || ln -s /usr/local/nginx-#{nginx_ver}/conf /etc/nginx
    test -x /usr/sbin/nginx || ln -s /usr/local/nginx-#{nginx_ver}/sbin/nginx /usr/sbin/nginx
    test -d /var/log/nginx || ln -s /usr/local/nginx-#{nginx_ver}/logs /var/log/nginx
    id nginx >/dev/null 2>&1 || useradd -d /var/www -s /bin/false nginx

    test -f /etc/systemd/system/nginx.service || \
      cp /misc/nginx.service /etc/systemd/system/nginx.service && systemctl daemon-reload
    rm -rf /etc/nginx/nginx.conf && \
      ln -s /misc/nginx/nginx.conf /etc/nginx/nginx.conf
    rm -rf /etc/nginx/conf.d && mkdir /etc/nginx/conf.d && \
      ln -s /misc/nginx/http.conf /etc/nginx/conf.d/http.conf && \
      ln -s /misc/nginx/stream.conf /etc/nginx/conf.d/stream.conf
    rm -rf /var/lib/mruby && ln -s /misc/mruby /var/lib/mruby

    openssl req -x509 -days 365 -newkey rsa:2048 -nodes \
      -out /etc/nginx/tls.crt -keyout /etc/nginx/tls.key \
      -subj "/C=/ST=/L=/O=/OU=/CN=#{common_name}" >/dev/null 2>&1

    systemctl enable nginx && systemctl start nginx
  SHELL
end
