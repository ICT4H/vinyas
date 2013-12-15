# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "peers"
  config.vm.box_url = "virtualboximages/centos-6.2-64bit-puppet-vbox.4.1.8-11.box"

  config.vm.network :private_network, ip: "192.168.33.11"
  config.vm.network :public_network
  config.ssh.username = "root"

  if ENV['STAGE'] == nil
    manifest_file = "do-nothing.pp"
  else
    manifest_file = ENV['STAGE'] + ".pp"
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = manifest_file
    puppet.module_path = "puppet/modules"
  end
end
