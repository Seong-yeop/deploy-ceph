#!/bin/env bash

rm -rf /var/lib/ceph/osd/*

UUID=$(uuidgen)
OSD_SECRET=$(ceph-authtool --gen-print-key)
ID=$(echo "{\"cephx_secret\": \"$OSD_SECRET\"}" | \
     ceph osd new $UUID -i - \
        -n client.bootstrap-osd -k /var/lib/ceph/bootstrap-osd/ceph.keyring)

mkdir -p /var/lib/ceph/osd/ceph-$ID
mkfs.xfs /dev/nvme1n1
mount /dev/nvme1n1 /var/lib/ceph/osd/ceph-$ID
ceph-authtool --create-keyring /var/lib/ceph/osd/ceph-$ID/keyring \
       --name osd.$ID --add-key $OSD_SECRET
ceph-osd -i $ID --mkfs --osd-uuid $UUID
chown -R ceph:ceph /var/lib/ceph/osd/ceph-$ID
echo 1831054687 > /var/lib/ceph/osd/ceph-$ID/bfm_blocks

sleep 1
systemctl enable ceph-osd@$ID
systemctl start ceph-osd@$ID
