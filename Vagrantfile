
ENV["LC_ALL"] = "en_US.UTF-8"
Vagrant.require_version ">= 2.2.10"
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
  end
  # disable swap check here https://serverfault.com/questions/881517/why-disable-swap-on-kubernetes
  config.vm.provision "shell", inline: "sudo swapoff -a && sudo sed -i '/swap/d' /etc/fstab" 
  config.vm.define "loadbalancer" do |lb|
    lb.vm.hostname = "loadbalancer"
    lb.vm.network "private_network", ip: "192.168.56.5"
  end

end