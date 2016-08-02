#! /bin/bash -x

# define your own provisioning stuff here, to run at the tail end of 'vagrant up'
# note that this script must return 0, either explicitly or implicitly, otherwise vagrant up will fail

STACKI_PATH=/opt/stack/bin/stack
if [[ -f /vagrant/hostfile.csv ]]; then
	$STACKI_PATH load hostfile file=/vagrant/hostfile.csv
	$STACKI_PATH set host attr backend attr=nukedisks value=true
	$STACKI_PATH set host boot backend action=install
fi

exit 0

