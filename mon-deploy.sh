#!/bin/env bash

MONHOSTNAME=`hostname -s`
echo $MONHOSTNAME 

#systemctl stop ceph.raget
#systemctl reset-failed

rm -rf /tmp/monmap
rm -rf /tmp/ceph*
#rm -rf /etc/ceph/ceph.conf

rm -rf /var/lib/ceph/mon/ceph-ip-172-31-0-136
mkdir -p /var/lib/ceph/bootstrap-osd
rm -rf /var/lib/ceph/bootstrap-osd/ceph.keyring
rm -rf /var/lob/ceph-mon*
rm -rf /etc/ceph/ceph.client.admin.keyring

sudo ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring


mkdir -p /var/lib/ceph/mon/ceph-ip-172-31-0-136

sudo chown -R ceph:ceph /var/log/ceph
sudo chown -R ceph:ceph /var/run/ceph
sudo chown -R ceph:ceph /var/lib/ceph
sudo chown -R ceph:ceph /tmp/ceph.mon.keyring
sudo chown -R ceph:ceph /etc/ceph/ceph.client.admin.keyring

monmaptool --create --add $MONHOSTNAME 172.31.0.136 --fsid 1e174f1e-8559-11eb-8520-d15a5aa7f296 /tmp/monmap
sudo chown -R ceph:ceph /tmp/monmap

sudo ceph-mon --mkfs -i $MONHOSTNAME --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
sudo chown -R ceph:ceph /var/lib/ceph

echo "sleep 3"
sleep 3

systemctl start ceph-mon@$MONHOSTNAME 
echo "mon start"

