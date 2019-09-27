# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/bionic64'
  config.vm.provider 'virtualbox' do |vb|
    vb.memory = 512
    vb.cpus = 1
  end

  autostart_bench = !!ENV['BENCH']
  autostart_smtp = !!ENV['SMTP']
  autostart_resource = !!ENV['RESOURCE']

  config.vm.define 'containers', autostart: !autostart_resource, primary: true do |c|
    c.disksize.size = '50GB'
    c.vm.provider 'virtualbox' do |vb|
      vb.memory = 512 * 6
      vb.cpus = 8
    end
    %w(80 443).each do |port|
      c.vm.network 'forwarded_port', guest: port, host: "8#{port.rjust(3, '0')}"
    end
    %w(22 25).each do |port|
      p = "8#{port.rjust(3, '0')}"
      c.vm.network 'forwarded_port', guest: p, host: p
    end
    c.vm.synced_folder './provision', '/data'
    c.vm.provision 'shell', path: 'provision/containers.sh'
    c.vm.hostname = 'containers'
    c.vm.network :private_network, ip:'192.168.30.10'
    c.vm.network :private_network, ip:'192.168.30.99'
  end

  config.vm.define :bench, autostart: autostart_bench do |c|
    c.disksize.size = '50GB'
    c.vm.provider 'virtualbox' do |vb|
      vb.memory = 512 * 2
      vb.cpus = 4
    end
    c.vm.synced_folder './out', '/opt/out'
    c.vm.synced_folder './bench', '/opt/bench'
    c.vm.provision 'shell', inline: (<<-SHELL)
apt update
apt -y install apache2-utils
    SHELL
    c.vm.network 'private_network', ip: '192.168.199.20'
  end

  # Comparison of the effect of the number of simultaneous connections
  config.vm.define 'smtp-server', autostart: autostart_smtp do |c|
    c.vm.provision 'file', source: './provision/hosts', destination: '/tmp/hosts'
    c.vm.provision 'shell', path: 'provision/smtp.sh'
    c.vm.hostname = 'smtp-server'
    c.vm.network :private_network, ip:'192.168.30.11'
  end

  config.vm.define 'smtp-client', autostart: autostart_smtp do |c|
    c.vm.provision 'file', source: './provision/hosts', destination: '/tmp/hosts'
    c.vm.provision 'file', source: './provision/sender.sh', destination: '/tmp/sender.sh'
    c.vm.provision 'shell', path: 'provision/smtp.sh'
    c.vm.provision 'shell', path: 'provision/client.sh'
    c.vm.hostname = 'smtp-client'
    c.vm.network :private_network, ip:'192.168.30.12'
  end

  config.vm.define 'smtp-rcpt', autostart: autostart_smtp do |c|
    c.vm.provision 'file', source: './provision/hosts', destination: '/tmp/hosts'
    c.vm.provision 'shell', path: 'provision/smtp.sh'
    c.vm.hostname = 'smtp-rcpt'
    c.vm.network :private_network, ip:'192.168.30.13'
  end

  config.vm.define 'smtp-tarpit', autostart: autostart_smtp do |c|
    c.vm.provision 'file', source: './provision/hosts', destination: '/tmp/hosts'
    c.vm.provision 'file', source: './provision/mxtarpit.service', destination: '/tmp/mxtarpit.service'
    c.vm.provision 'shell', path: 'provision/smtp-tarpit.sh'
    c.vm.hostname = 'smtp-tarpit'
    c.vm.network :private_network, ip:'192.168.30.14'
  end

  # Resource usage comparison
  config.vm.define 'postfix', autostart: autostart_resource do |c|
    c.vm.synced_folder './provision', '/data'
    c.vm.provision 'shell', path: 'provision/postfix.sh'
    c.vm.hostname = 'postfix'
    c.vm.network :private_network, ip:'192.168.30.15'
  end

  config.vm.define 'docker', autostart: autostart_resource do |c|
    c.vm.provision 'shell', path: 'provision/docker.sh'
    c.vm.hostname = 'docker'
    c.vm.network :private_network, ip:'192.168.30.16'
  end

  config.vm.define 'fastcon', autostart: autostart_resource do |c|
    c.vm.provision 'shell', path: 'provision/fastcon.sh'
    c.vm.hostname = 'fastcon'
    c.vm.network :private_network, ip:'192.168.30.17'
  end
end
