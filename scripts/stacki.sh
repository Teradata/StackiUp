#! /bin/bash

# give the vagrant user access to stacki commands
cat >> /home/vagrant/.stackipathrc <<EOF
export PATH=\$PATH:/opt/stack/bin:/opt/stack/sbin
EOF

source /home/vagrant/.stackipathrc
/opt/stack/bin/stack set access command="*" group=vagrant

