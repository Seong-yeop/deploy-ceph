#!/bin/env bash

rgw_hostname=`hostname`

rm /var/lib/ceph/radosgw/*
mkdir -p /var/lib/ceph/radosgw/ceph-rgw.$rgw_hostname
ceph auth get-or-create client.rgw.$rgw_hostname osd 'allow rwx' mon 'allow rw' -o /var/lib/ceph/radosgw/ceph-rgw.$rgw_hostname/keyring
touch /var/lib/ceph/radosgw/ceph-rgw.$rgw_hostname/done

chown -R ceph:ceph /var/lib/ceph/radosgw
chown -R ceph:ceph /var/log/ceph
chown -R ceph:ceph /var/run/ceph
chown -R ceph:ceph /etc/ceph

systemctl enable ceph-radosgw.target
systemctl enable ceph-radosgw@rgw.$rgw_hostname
systemctl start ceph-radosgw@rgw.$rgw_hostname
