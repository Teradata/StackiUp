# StackUp

StackUp is a collection of files to create a complete virtual Stacki environment, based around common devops tools such as Packer, Vagrant and VirtualBox.

Stacki has greater software requirements than typical Vagrant boxes offer, and as such you're best off building a Vagrant box manually with Packer, as opposed to using one of the popular ones found online.

> On Dependencies: If you don't have packer, vagrant and VirtualBox installed, you'll need these, of course.  On MacOSX, homebrew has vagrant and packer, otherwise you can find them at http://vagrantup.com and http://packier.io

## Packer
To start, grab the CentOS 7 "everything" ISO, as well as the latest and greatest Stacki 3.2

    $ wget http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Everything-1511.iso

Place these in the `./isos/` folder, and ensure that the md5sum for CentOS "everything" matches what's listed in `./centos.json`.

    $ packer build centos.json

If you're not familiar with packer, don't be alarmed when you see VirtualBox pop up and begin to install CentOS, using a kickstart file found in `./http/ks.cfg`.

The install should take a few minutes (as they do...).  It's possible that Packer will timeout if it takes too long.  If that happens, edit `./centos.json` and set "ssh\_wait\_timeout" to something higher.

## Vagrant
Once the build completes successfully, you can add your shiny new box to Vagrant!  The box output by Packer will be called something like `./Centos.7-virtualbox.box`.

    $ vagrant box add --name stacki/centos7 Centos.7-virtualbox.box

You can set name to whatever you like.  Whatever you called it, open up `./Vagrantfile` and change the following line to reflect the name you chose:

      config.vm.box = "stacki/centos7"

While you're in there, poke around.  There's a line that defines what network Vagrant should create (defaults to '192.168.42.' for no other reason than the number 42 rocks.).  You can modify that, but it needs to be a /24 network!  Vagrant will create this network (if it needs to) as a Host-only network.

Once you're satisfied with the Vagrantfile, run it.

    $ vagrant up

Again, this will take a few minutes as it builds the VM around the box we created, and then begins to install Stacki for you *as if by magic*.  Go grab a coffee.  You deserve it.

Once `vagrant up` returns you'll see the last message printed instructs you to `vagrant halt && vagrant up`.  Do this as stacki requires a reboot after frontend installation and rebooting from within the virtual machine environment doesn't always setup some of the Vagrant niceties we'll be using momentarily.  Should only take a second.

    $ vagrant halt && vagrant up

Once it comes back up, `vagrant ssh` will bring you into your new virtual Stacki frontend machine.  If you're not familiar with Vagrant, take a peak at `/vagrant/` in the VM and you'll see what has been our working directory up until now.  Vagrant automatically sets up a number of things (including the ssh keys and port forwarding) and these shared guest folders are one of them.  This will come in handy later.

## VirtualBox
If you're in the VM environment, `exit` to get back to our host machine.  Looking around, you'll see a script called `create_backend_machines.sh`.  Run that, with some number of VM's you'd like to create.

    $ create_backend_machines.sh 3

This wraps around VirtualBox's `VBoxManage` CLI utility, pokes inside our shiny new Vagrant VM, and creates *N* VM's, in the same network as our Frontend, all set and ready to go.  As an added bonus, it also creates a hostfile kicksheet (`./hostfile.csv`) for you, based on those VM's.

    $ cat hostfile.csv 
    Name,Appliance,Rack,Rank,IP,MAC,Interface,Network,Default
    compute-0,backend,0,0,__IPADDRESS__,08:00:27:97:2D:56,eth0,private,True
    compute-1,backend,0,1,__IPADDRESS__,08:00:27:1A:C5:C3,eth0,private,True
    compute-2,backend,0,2,__IPADDRESS__,08:00:27:27:D9:90,eth0,private,True

The only thing you need to do is edit the IP address column (in a future release, we might automatically add these as well).  Make sure you remember the network address you chose, and also that our Vagrant-installed Frontend sits at THAT\_NETWORK\_ADDRESS.*101*.  Just make your life a little bit easier and number them .151-.15*N*

## Stacki
Go back into the Vagrant instance:

    $ vagrant ssh

Remember the shared guest folder?  Guess what, our `hostfile.csv` kicksheet is in there.  From here, we can load the hostfile into Stacki.  StackUp helpfully created a vagrant user, and gave them sudo permissions inside the VM.  It's worth mentioning that if needed the root password is simply 'root'.

    $ sudo -i stack load hostfile file=/vagrant/hostfile.csv
    $ stack list host
    HOST            RACK RANK CPUS APPLIANCE BOX     ENVIRONMENT RUNACTION INSTALLACTION
    stackifrontend: 0    0    1    frontend  default ----------- os        install      
    compute-0:      0    0    1    backend   default ----------- os        install      
    compute-1:      0    1    1    backend   default ----------- os        install      
    compute-2:      0    2    1    backend   default ----------- os        install      

Our Vagrant VM's peers are now added to Stacki's database, and we can manage them.  Set them to install:

    $ sudo -i stack set host attr backend attr=nukedisks value=true
    $ sudo -i stack set host boot backend action=install

... and start them up in Virtualbox on your host machine.  Be gentle in doing so, as starting the install of all of the VM's at once can cause issues when the Frontend is also a VM.  Just space them out a few seconds and you should be fine.

When you're tired of it (or you broke something -- hey, it happens), you can exit out of the Vagrant vm, and then issue `vagrant destroy`, knowing that you can `vagrant up` again at any time.
