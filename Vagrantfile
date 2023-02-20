ENV["LC_ALL"] = "en_US.UTF-8"
Vagrant.require_version ">= 2.2.10"
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
    v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
  end
  # disable swap check here https://serverfault.com/questions/881517/why-disable-swap-on-kubernetes
  # LB
  config.vm.provision "shell", inline: "sudo swapoff -a && sudo sed -i '/swap/d' /etc/fstab" 
  config.vm.define "loadbalancer" do |lb|
    lb.vm.hostname = "loadbalancer"
    lb.vm.network "private_network", ip: "192.168.56.5"
    lb.vm.provision "ansible_local" do |ansible|
      lb.vm.synced_folder "/mnt/c/Users/tucot/projects/k8s-hard-way", "/vagrant"
      ansible.playbook = "00-playbooks/playbook.yml"
      ansible.galaxy_role_file = "00-playbooks/requirements.yml"
    end
  end

  # Control plane
  (1..3).each do |i|
    config.vm.define "controller-#{i}" do |controller|
      controller.vm.hostname = "controller-#{i}"
      controller.vm.network "private_network", ip: "192.168.56.1#{i}"
    end
  end

  # # Nodes
  # (1..2).each do |i|
  #   config.vm.define "node-#{i}" do |node|
  #     node.vm.hostname = "node-#{i}"
  #     node.vm.network "private_network", ip: "192.168.56.2#{i}"
  #     node.vm.provision "shell",
  #       inline: "sudo swapoff -a && sudo sed -i '/swap/d' /etc/fstab && sudo sed -i '/GRUB_CMDLINE_LINUX=/d' /etc/default/grub && echo GRUB_CMDLINE_LINUX=systemd.unified_cgroup_hierarchy=false | sudo tee /etc/default/grub && sudo update-grub && sudo reboot"
  #   end
  # end

end