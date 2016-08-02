# StackUp

StackUp is a collection of files to create a complete virtual Stacki environment, based around common devops tools such as Packer, Vagrant and VirtualBox.

Stacki has greater software requirements than typical Vagrant boxes offer, and as such you're best off using our purpose-built Vagrant box {{available on S3}}, as opposed to using one of the popular ones found online.  Building your own Vagrant box from our template should be possible in the next release of Stacki -- see the FAQ at the bottom.

> On Dependencies: If you don't have Vagrant and VirtualBox installed, you'll need these, of course.  On MacOSX, homebrew has vagrant, otherwise you can find it at [VagrantUp.com](http://vagrantup.com).

See the end of the document for known issues, TODO, advanced topics, etc.

## Vagrant
Once you've downloaded your shiny new Vagrant box, you need to add it to Vagrant!

    $ vagrant box add --name stacki/stackios ./builds/StackiOS-3.2.1-7.x-virtualbox.box

You can set the name to whatever you like.  If you picked something other than 'stacki/stackios', open up `./Vagrantfile` and change the following line to reflect the name you chose:

      config.vm.box = "stacki/stackios"

Once you're satisfied with the Vagrantfile, run Vagrant.

    $ vagrant up

Again, this will take a minute (but not much more than that) as it builds the VM around the box we created.  Go grab a coffee.  You deserve it.

By default Vagrant machines run in headless mode to stay out of your way.  Vagrant also automatically sets up a number of things on the guest VM, including the ssh keys and port forwarding.

Once it comes back up, `vagrant ssh` will bring you into your new virtual Stacki Frontend machine.  If you're not familiar with Vagrant, take a peak at `/vagrant/` inside the VM and you'll see what has been our working directory up until now.  This is a shared guest folder Vagrant has set up to allow you to easily interact with files on both the host and the VM.  This will come in handy in a minute.

## VirtualBox
If you're in the VM environment, `exit` to get back to our host machine.  Looking around our working directory, you'll see a script called `create_backend_machines.sh`.  Run that, with some number of VM's you'd like to create (keeping in mind the physical limitations of your hardware!).

    $ create_backend_machines.sh 3

This wraps around VirtualBox's `VBoxManage` CLI utility, pokes inside our shiny new Vagrant VM, and creates *N* VM's, in the same virtual network as our Frontend, all set and ready to go.  As an added bonus, it also creates a hostfile kicksheet (`./hostfile.csv`) for you, based on those VM's.

    $ cat hostfile.csv 
    Name,Appliance,Rack,Rank,IP,MAC,Interface,Network,Default
    compute-0,backend,0,0,192.168.42.100,08:00:27:97:2D:56,eth0,private,True
    compute-1,backend,0,1,192.168.42.101,08:00:27:1A:C5:C3,eth0,private,True
    compute-2,backend,0,2,192.168.42.102,08:00:27:27:D9:90,eth0,private,True

If you haven't edited any files along the way, by default (as of this writing!) our Vagrant-installed Frontend sits at _192.168.42.10_.

> PS: If you don't use this script to make your backend VM's, be sure to check the Stacki wiki on Github for the minimum "hardware" requirements for backend nodes!  Mysterious and puzzling things can happen if you try to make backend nodes too small.

## Stacki
Go back into the Vagrant instance:

    $ vagrant ssh

Remember the shared guest folder, `/vagrant/`?  Guess what, since we created the hostfile in the current working directory, our `hostfile.csv` kicksheet is accessible in our VM too.  From here, we can load the hostfile into Stacki.  StackUp helpfully created a vagrant user, and gave them sudo permissions inside the VM.

> It's worth mentioning that if needed the root password in our StackUp repo defaults to 'password'.  See the FAQ about changing it.

    $ sudo -i stack load hostfile file=/vagrant/hostfile.csv
    $ stack list host
    HOST            RACK RANK CPUS APPLIANCE BOX     ENVIRONMENT RUNACTION INSTALLACTION
    stackifrontend: 0    0    1    frontend  default ----------- os        install      
    compute-0:      0    0    1    backend   default ----------- os        install      
    compute-1:      0    1    1    backend   default ----------- os        install      
    compute-2:      0    2    1    backend   default ----------- os        install      

Our Vagrant VM's peers are now added to Stacki's database, and we can manage them from inside our VM.  Set them to install:

    $ sudo -i stack set host attr backend attr=nukedisks value=true
    $ sudo -i stack set host boot backend action=install

... and start them up in Virtualbox on your host machine.

After a few minutes, you'll have an additional _N_ backend/compute nodes deployed.  Congratulations, you've got a working Stacki install!

Now you're free to go find (or create!) additional Stacki Pallets, to allow for more complex deployments.  For example, you can add the CentOS Everything ISO as a pallet to give your backend nodes access to all of the packages available there.

When you're tired of it (or you broke something -- hey, it happens), you can exit out of the Vagrant VM, and then issue `vagrant destroy`, knowing that you can `vagrant up` again at any time.

## What Else?

### Uses (aka, why?)

__Kicking the tires__.  Stacki-as-open-source is fairly new, so many people don't yet know what you can do with it.  StackUp gives you a chance to play with Stacki from the convenience of your (admittedly somewhat beefy) laptop.

__Automation of testing__.  With StackUp, a configuration management tool such as Ansible, and a little bit of scripting, you should be able to test infrastructure changes.  Internally, Stacki developers should be able to pair the above with a Continuous Integration tool to help speed up some of our pre-release integration tests, which means more Stacki for you, Dear Reader.

__Ease of development__.  Obviously helpful more for developers, but the ability to skip the install saves time.  Vagrant also provides several time-saving features.  It runs VMs in headless mode by default.  It uses SSH keys for logging into the VM, forwards ports, and shares folders between host and VM.  These features can be easily extended in the Vagrantfile, for example if you need an additional port forwarded, or other shared folders.

__Running your whole enterprise infrastructure__.  Are you crazy?


### Limitations

* Currently, StackUp focuses only on VirtualBox.  As such, it borrows some of that tool's own limitations (you can't have nested VM's, for example).  Other hypervisors should be possible (Packer and Vagrant support several), but are unplanned.
* StackUp relies on an unreleased development version of StackiOS because it requires a modification to the Anaconda installer.  The changes are in upstream Stacki already and will be in the next release.

### TODO

* Release the next version of Stacki so people can spin up their own Vagrant boxes using Packer!  In the meantime, you can still use our lovingly crafted Vagrant box, by downloading it from this link: `<<STACKIOS VAGRANT BOX>>`

### FAQ

* "My frontend/backend nodes don't make it through the install."

Remember that Stacki is a tool designed for provisioning nodes on a *very* large scale.  It is possible you've found a bug, but before letting us know, please be sure to check the minimum hardware requirements for [Frontend](https://github.com/StackIQ/stacki/wiki/Frontend-Installation#requirements) and [Backend](https://github.com/StackIQ/stacki/wiki/Backend-Installation#requirements) VM's all meet them.

* "I want to customize the StackUp install to use a different network."

See the above TODO note about changes required to the installer.  When the next version of Stacki is released, you'll be able to use the `stack_adder.py` script to set whatever modifications you need prior to running Packer.

* "I want to change the password!"

You can change the password once the Vagrant VM is up and running.  Log in to the VM and do `sudo -i stack set password`.

Otherwise, see the previous FAQ about changing networking.  When the next Stacki release is available, changing the password in site.attrs will work but will also require changing the password referenced in `./stackios.json`.

* "Can you add SUPER\_IMPORTANT\_FEATURE?"

I dunno, probably, but probably not right away.  But, once the next version of StackiOS is released all the bits are out there, so if you have a specific need and a patch that looks good, we can probably merge it.

* The Vagrant Stacki Frontend comes up, and everything looks right, but my backend nodes won't DHCP boot.

Stacki Frontends run their own DHCP server, but VirtualBox tries do to this as well.  You can run `VBoxManage list hostonlyifs` and check that the DHCP server is disabled for that virtual network.

However, it's possible VBox didn't kill its server and is *still running a DHCP server on that network anyway*.  Running `ps aux | grep -i vb | grep -i dhcp` should show any DHCP processes that VBox might still be running.  I found a running a DHCP server on vboxnet0 serving in the range 192.168.56.0 (which was weird, as I changed vboxnet0 to 192.168.42.0).  At any rate, killing that process and rebooting my backend nodes allowed them to boot.

* "Something else isn't working."

Again, totally possible it's a bug in StackUp (there's a lot of moving parts here), but at the time of this writing, the most recent versions of VirtualBox (5.1) and Vagrant (1.8.5) both have significant regressions for this workflow.  If you run into issues (particularly with networking/ssh), drop back to VBox 5.0.x and Vagrant 1.8.4, if at all possible.  The issues in Vagrant at least are supposed to be fixed in 1.8.6.  For what it's worth, this project was developed on MacOSX 11.4, with VBox 5.0.18 and Vagrant 1.8.1.

> [Vagrant #7648](https://github.com/mitchellh/vagrant/issues/7648)

> [Vagrant #7667](https://github.com/mitchellh/vagrant/issues/7667)

> [VBox #15705](https://www.virtualbox.org/ticket/15705)
