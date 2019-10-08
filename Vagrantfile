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

  config.vm.define 'containers', primary: true do |c|
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
    c.vm.provision 'shell', path: 'provision/containers/script.sh'
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

  config.vm.define 'monolith', autostart: autostart_smtp do |c|
    c.vm.synced_folder './provision', '/data'
    c.vm.provision 'file', source: './provision/hosts', destination: '/tmp/hosts'
    c.vm.provision 'shell', path: 'provision/postfix.sh'
    c.vm.provision 'shell', path: 'provision/monolith/script.sh'
    c.vm.hostname = 'monolith'
    c.vm.network :private_network, ip:'192.168.30.11'
  end

  config.vm.define 'sender', autostart: autostart_smtp do |c|
    c.vm.provision 'file', source: './provision/hosts', destination: '/tmp/hosts'
    c.vm.provision 'shell', path: 'provision/postfix.sh'
    c.vm.provision 'shell', path: 'provision/sender/script.sh'
    c.vm.hostname = 'sender'
    c.vm.network :private_network, ip:'192.168.30.12'
  end

  config.vm.define 'recipient', autostart: autostart_smtp do |c|
    c.vm.provision 'file', source: './provision/hosts', destination: '/tmp/hosts'
    c.vm.provision 'shell', path: 'provision/postfix.sh'
    c.vm.hostname = 'recipient'
    c.vm.network :private_network, ip:'192.168.30.13'
  end

  config.vm.define 'mxtarpit', autostart: autostart_smtp do |c|
    c.vm.provision 'file', source: './provision/hosts', destination: '/tmp/hosts'
    c.vm.provision 'file', source: './provision/mxtarpit/mxtarpit.service', destination: '/tmp/mxtarpit.service'
    c.vm.provision 'shell', path: 'provision/mxtarpit/script.sh'
    c.vm.hostname = 'mxtarpit'
    c.vm.network :private_network, ip:'192.168.30.14'
  end
end
