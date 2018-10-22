# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/xenial64'

  %w(80 443).each do |port|
    config.vm.network 'forwarded_port', guest: port, host: "8#{port.rjust(3, '0')}"
  end

  %w(22 25).each do |port|
    p = "8#{port.rjust(3, '0')}"
    config.vm.network 'forwarded_port', guest: p, host: p
  end

  config.vm.network 'forwarded_port', guest: 19999, host: 19999

  config.vm.provider 'virtualbox' do |vb|
    vb.memory = 512 * 6
    vb.cpus = 8
  end

  config.vm.synced_folder './provision', '/data'
  config.vm.provision 'shell', path: 'provision/provisioner.sh'

  config.disksize.size = '50GB'
end
