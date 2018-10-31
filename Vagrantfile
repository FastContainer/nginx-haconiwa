# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/bionic64'
  config.vm.provider 'virtualbox' do |vb|
    vb.memory = 512
    vb.cpus = 1
  end

  hosts = <<-HOSTS
  grep 192.168.30 /etc/hosts >/dev/null
  if [ $? -eq 1 ]; then
    cat <<EOF >> /etc/hosts
  192.168.30.10 containers.test
  192.168.30.11 smtp-server.test
  192.168.30.12 smtp-client.test
  192.168.30.13 smtp-rcpt.test
  EOF
  fi
  HOSTS

  config.vm.define 'containers', primary: true do |c|
    c.vm.network 'forwarded_port', guest: 19999, host: 9000

    %w(80 443).each do |port|
      c.vm.network 'forwarded_port', guest: port, host: "8#{port.rjust(3, '0')}"
    end

    %w(22 25).each do |port|
      p = "8#{port.rjust(3, '0')}"
      c.vm.network 'forwarded_port', guest: p, host: p
    end

    c.vm.synced_folder './provision', '/data'
    c.vm.provision 'shell', path: 'provision/containers.sh'
    c.vm.provision 'shell', inline: hosts
    c.vm.hostname = 'containers'
    c.vm.network :private_network, ip:'192.168.30.10'
  end


  config.vm.define 'smtp-server', autostart: false do |c|
    c.vm.network 'forwarded_port', guest: 19999, host: 9001
    c.vm.provision 'shell', path: 'provision/smtp.sh'
    c.vm.provision 'shell', inline: hosts
    c.vm.hostname = 'smtp-server'
    c.vm.network :private_network, ip:'192.168.30.11'
  end

  config.vm.define 'smtp-client', autostart: false do |c|
    c.vm.network 'forwarded_port', guest: 19999, host: 9002
    c.vm.provision 'shell', path: 'provision/smtp.sh'
    c.vm.provision 'shell', inline: hosts
    c.vm.hostname = 'smtp-client'
    c.vm.network :private_network, ip:'192.168.30.12'
  end

  config.vm.define 'smtp-rcpt', autostart: false do |c|
    c.vm.network 'forwarded_port', guest: 19999, host: 9003
    c.vm.provision 'shell', path: 'provision/smtp.sh'
    c.vm.provision 'shell', inline: hosts
    c.vm.hostname = 'smtp-rcpt'
    c.vm.network :private_network, ip:'192.168.30.13'
  end
end
