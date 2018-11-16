# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/bionic64'
  config.vm.provider 'virtualbox' do |vb|
    vb.memory = 512
    vb.cpus = 1
  end

  config.vm.define 'containers', primary: true do |c|
    %w(80 443).each do |port|
      c.vm.network 'forwarded_port', guest: port, host: "8#{port.rjust(3, '0')}"
    end
    %w(22 25).each do |port|
      p = "8#{port.rjust(3, '0')}"
      c.vm.network 'forwarded_port', guest: p, host: p
    end
    c.vm.network 'forwarded_port', guest: 19999, host: 9000
    c.vm.synced_folder './provision', '/data'
    c.vm.provision 'shell', path: 'provision/containers.sh'
    c.vm.hostname = 'containers'
    c.vm.network :private_network, ip:'192.168.30.10'
  end

  autostart = !!ENV['SMTP']

  config.vm.define 'smtp-server', autostart: autostart do |c|
    c.vm.provision 'file', source: './provision/hosts', destination: '/tmp/hosts'
    c.vm.provision 'shell', path: 'provision/smtp.sh'
    c.vm.hostname = 'smtp-server'
    c.vm.network :private_network, ip:'192.168.30.11'
  end

  config.vm.define 'smtp-client', autostart: autostart do |c|
    c.vm.provision 'file', source: './provision/hosts', destination: '/tmp/hosts'
    c.vm.provision 'shell', inline: <<-CMD
      grep 192.168.30 /etc/hosts >/dev/null || cat /tmp/hosts >> /etc/hosts
      apt update -y
      apt install -y curl
      locale-gen ja_JP.UTF-8
    CMD
    c.vm.hostname = 'smtp-client'
    c.vm.network :private_network, ip:'192.168.30.12'
  end

  config.vm.define 'smtp-rcpt', autostart: autostart do |c|
    c.vm.provision 'file', source: './provision/hosts', destination: '/tmp/hosts'
    c.vm.provision 'shell', path: 'provision/smtp.sh'
    c.vm.hostname = 'smtp-rcpt'
    c.vm.network :private_network, ip:'192.168.30.13'
  end
end
