#!/bin/sh

:<<END
END

sudo rm -rf /etc/ceph
sudo rm -rf /var/lib/ceph
sudo rm -rf /tmp/*

fsid=`uuidgen`
cluster_name=ceph
hostname=hpc5
ip_address=192.168.10.14

echo "[global]" > ceph.conf
echo "fsid = $fsid" >> ceph.conf
echo "mon initial members = $hostname" >> ceph.conf
echo "mon host = $ip_address" >> ceph.conf
sudo mkdir -p /etc/ceph
sudo mkdir -p /var/lib/ceph/bootstrap-osd
sudo cp ceph.conf /etc/ceph/ceph.conf
sudo -u ceph ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
#monmaptool --create --clobber --add $hostname $ip_address --fsid $fsid /tmp/monmap
sudo -u ceph monmaptool --create --add $hostname $ip_address --fsid $fsid /tmp/monmap
sudo mkdir -p /var/lib/ceph/mon/${cluster_name}-${hostname}
sudo chown -R ceph:ceph /var/lib/ceph
sudo chown -R ceph:ceph /etc/ceph
sudo chmod +r /etc/ceph/ceph.client.admin.keyring
sudo chmod +r /var/lib/ceph/bootstrap-osd/ceph.keyring
sudo chmod +r /tmp/ceph.mon.keyring
sudo chmod 777 /var/lib/ceph/mon/${cluster_name}-${hostname}
sudo -u ceph ceph-mon --mkfs -i $hostname --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
sudo chmod +r /var/lib/ceph/mon/${cluster_name}-${hostname}/keyring

echo "public network = 192.168.10.0/24
cluster network = 192.168.10.0/24
auth cluster required = cephx
auth service required = cephx
auth client required = cephx
osd journal size = 1024
osd pool default size = 1
osd pool default pg num = 128
osd pool default pgp num = 128
osd crush chooseleaf type = 1" >> ceph.conf
sudo cp ceph.conf /etc/ceph/ceph.conf

sudo touch /var/lib/ceph/mon/${cluster_name}-${hostname}/done
#sudo /etc/init.d/ceph start mon.$hostname
#sudo systemctl start ceph-mon@$hostname
#sudo start ceph-mon id=$hostname
#sudo touch /var/lib/ceph/mon/${cluster_name}-${hostname}/upstart
#ceph -s
