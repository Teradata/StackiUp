#! /bin/bash -x

# Fix the gateway to point to the NAT network interface so we can get out
sed -i -r "s/^GATEWAY=.*$/GATEWAY=10.0.2.2/" /etc/sysconfig/network

# don't up/down the whole network, as the private iface will complain
ifdown enp0s3
ifup enp0s3

# Fix the MAC address of the private network iface
NEW_MAC=`sed -n -r "s/Kickstart_PrivateEthernet:(.*)/\1/p" /tmp/site.attrs`
IFACE=`sed -n -r "s/Kickstart_PrivateInterface:(.*)/\1/p" /tmp/site.attrs`

echo "Shutting down ${IFACE}"
ifdown ${IFACE}

echo "Setting ${IFACE} to use MAC address ${NEW_MAC}"
echo sed -i.bak -r "s/HWADDR=.*$/MACADDR=${NEW_MAC}/" /etc/sysconfig/network-scripts/ifcfg-${IFACE}
sed -i.bak -r "s/HWADDR=.*$/MACADDR=${NEW_MAC}/" /etc/sysconfig/network-scripts/ifcfg-${IFACE}

ifup ${IFACE}

# don't care if the ${IFACE} isn't all the way up yet, it should be next boot
exit 0
