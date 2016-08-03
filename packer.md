## Packer
> As of Stacki commit 4c626a9 (post Stacki 3.2), we can use the StackiOS ISO directly to create a Vagrant Box.  It is also possible to create a CentOS box and perform an "existing install" of Stacki (lovingly called a Barnacle Install internally), but the process is longer and results in a much bigger Vagrant Box.

To start, grab the StackiOS ISO

    $ wget <<STACKIOS 3.2.1 ISO>>

Place it in the `./isos/` folder, and ensure that the md5sum matches what's listed at the end of `./stackios.json`.

    $ packer build stackios.json

If you're not familiar with Packer, don't be alarmed when you see VirtualBox pop up and begin to install StackiOS, using a kickstart file found in `./http/ks.cfg`.  Don't bother editing that kickstart file - during the installation of a Frontend, Stacki creates its own kickstart file and restarts the Anaconda installer using that one.

The install should take a few minutes (as they do...).  At some point, the OS will finish installing and reboot, and then begin to run scripts contained in the `./scripts/` directory.  Finally, the VM will shut down again and the packer command will return.

> It's possible that Packer will timeout if it takes too long.  If that happens, edit `./stackios.json` and set "ssh\_wait\_timeout" to something higher.

