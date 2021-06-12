#!/bin/env bash

rgw_hostname=`hostname -s`

systemctl stop ceph.target

rm -rf /var/lib/ceph/radosgw/*

for i in {1..4}; do
  rgw="${rgw_hostname}-${i}"
  echo "${rgw} starting" 
  mkdir -p /var/lib/ceph/radosgw/ceph-rgw.$rgw
  ceph auth get-or-create client.rgw.$rgw osd 'allow rwx' mon 'allow rw' -o /var/lib/ceph/radosgw/ceph-rgw.$rgw/keyring
  touch /var/lib/ceph/radosgw/ceph-rgw.$rgw/done

  chown -R ceph:ceph /var/lib/ceph/radosgw
  chown -R ceph:ceph /var/log/ceph
  chown -R ceph:ceph /var/run/ceph
  chown -R ceph:ceph /etc/ceph
	
  if [ ${i} -eq 1 ];then
    systemctl enable ceph-radosgw.target
  fi
  systemctl enable ceph-radosgw@rgw.$rgw
  systemctl start ceph-radosgw@rgw.$rgw

done 

