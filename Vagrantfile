# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/bionic64'

  config.vm.define :default do |c|
    %w(80 443).each do |port|
      c.vm.network 'forwarded_port', guest: port, host: "8#{port.rjust(3, '0')}"
    end

    %w(22 25).each do |port|
      p = "8#{port.rjust(3, '0')}"
      c.vm.network 'forwarded_port', guest: p, host: p
    end

    c.vm.network 'forwarded_port', guest: 19999, host: 19999
    c.vm.network "private_network", ip: "192.168.199.10"

    c.vm.provider 'virtualbox' do |vb|
      vb.memory = 512 * 6
      vb.cpus = 8
    end

    c.vm.synced_folder './provision', '/data'
    c.vm.provision 'shell', path: 'provision/provisioner.sh'

    c.disksize.size = '50GB'
  end

  config.vm.define :bench do |c|
    c.vm.network "private_network", ip: "192.168.199.20"

    c.vm.provider 'virtualbox' do |vb|
      vb.memory = 512 * 2
      vb.cpus = 4
    end
    c.disksize.size = '50GB'

    c.vm.synced_folder './out', '/opt/out'
    c.vm.synced_folder './bench', '/opt/bench'
    c.vm.provision 'shell', inline: (<<-SHELL)
apt update
apt -y install apache2-utils
    SHELL
  end
end
