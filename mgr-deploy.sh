#!/bin/env bash

MGRHOSTNAME=`hostname -s`
echo $MGRHOSTNAME

rm -rf /var/lib/ceph/mgr/ceph-$MGRHOSTNAME
mkdir -p /var/lib/ceph/mgr/ceph-$MGRHOSTNAME

ceph auth get-or-create mgr.$MGRHOSTNAME mon 'allow profile mgr' osd 'allow *' mds 'allow *' > mgrkeyring
echo "Created auth"

cp mgrkeyring /var/lib/ceph/mgr/ceph-$MGRHOSTNAME/keyring
chown -R ceph:ceph /var/lib/ceph/mgr

echo "Starting mgr daemon"
ceph-mgr -i $MGRHOSTNAME
echo "Started mgr daemon"
