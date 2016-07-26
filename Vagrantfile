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

# Adjust the VM networking based on the contents of site.attrs
mac_addr = ''
ip_addr = ''
iface = ''

File.open("./http/site.attrs").each_line do |line|
  key, value = line.split(':', 2)
  if key == "Kickstart_PrivateEthernet"
    mac_addr = value.strip
  elsif key == "Kickstart_PrivateAddress"
    ip_addr = value.strip
  elsif key == "Kickstart_PrivateInterface"
    iface = value.strip
  end
end

Vagrant.configure(2) do |config|
  config.vm.box = "stacki/stackios"

  # Add a nic for a backend install network
  config.vm.network "private_network", ip: ip_addr, :mac => mac_addr.tr(':', '')

  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.memory = "3072"

    # give the VM a pretty name in VBox Manager
    time = Time.new
    vb.name = "StackiFrontend-3.2-" + time.strftime("%Y-%m-%d-%H-%M-%S")

    # Display the VirtualBox GUI when booting the machine
    vb.gui = gui_enabled?
 
  end

  # if defined, connect the stacki src dir, and forward the SSH agent
  if src_enabled?
    config.ssh.forward_agent = true
    config.vm.synced_folder ENV['STACKI_SRC'], "/export/src/"
  end

  # fix the VM networking to reflect what's in site.attrs
  # note that we actually changed the MAC of that NIC above, so we want to match here
  # and delete any references to overriding it in software ('macaddr=')
  config.vm.provision "shell", env: {"iface" => iface, "new_mac" => mac_addr}, inline: <<-SHELL
    ifdown ${iface}
    sed -i -r "s/HWADDR=.*$/HWADDR=${new_mac}/" /etc/sysconfig/network-scripts/ifcfg-${iface}
    sed -i -r "s/MACADDR=.*$/HWADDR=${new_mac}/" /etc/sysconfig/network-scripts/ifcfg-${iface}
    ifup ${iface}
  SHELL


end
