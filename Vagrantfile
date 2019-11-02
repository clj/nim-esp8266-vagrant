# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/debian-10"

  config.vm.synced_folder "synced/", "/home/vagrant/synced/"
  config.vm.synced_folder "saltstack/srv", "/srv/"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.linked_clone = true
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "on"]
  end

  config.ssh.forward_agent = true

  config.vm.provision :salt do |salt|
    salt.masterless = true
    salt.minion_config = "saltstack/etc/minion"
    salt.bootstrap_script = "saltstack/bin/bootstrap_salt.sh"
    salt.run_highstate = true
  end
end
