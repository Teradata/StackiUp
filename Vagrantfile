# -*- mode: ruby -*-
# vi: set ft=ruby :

# Returns true if `GUI` environment variable is set to a non-empty value.
# Defaults to false
def gui_enabled?
  !ENV.fetch('GUI', '').empty?
end

# optionally connect the VM to a src dir. set STACKI_SRC=/PATH/TO/SRC/
def src_enabled?
  !ENV.fetch('STACKI_SRC', '').empty?
end

# stacki has some minimum requirements above what's provided by most vagrant boxes
# this includes >2gb of ram, 64GB of disk, and a dedicated non-NAT nic
# for details, see https://github.com/StackIQ/stacki/wiki/Frontend-Installation 

backend_network = '10.168.42.'

Vagrant.configure(2) do |config|
  config.vm.box = "stacki/centos7"

  # Add a nic for a backend install network
  config.vm.network "private_network", ip: backend_network + "101", :mac => "0800d00dc189"

  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "3072"

    # give the VM a pretty name in VBox Manager
    time = Time.new
    vb.name = "StackiFrontend-3.2-" + time.strftime("%Y-%m-%d-%H-%M-%S")

    # Display the VirtualBox GUI when booting the machine
    vb.gui = gui_enabled?
 
  end

  # if defined, connect the stacki src dir, and forward SSH
  if src_enabled?
    config.ssh.forward_agent = true
    config.vm.synced_folder ENV['STACKI_SRC'], "/export/src/"
  end

  # VM provisioning #

  # vagrant will insert the vagrant/ruby variable backend_network as a shell variable
  config.vm.provision "shell", env: {"backend_network" => backend_network}, inline: <<-SHELL
    sed -i -r "s/BACKEND_NETWORK_ADDRESS/$backend_network/" /vagrant/vagrant_provisioning/site.attrs
  SHELL

  # finally, install stacki!
  config.vm.provision :shell, path: "vagrant_provisioning/do_stacki3.2.sh"
end
