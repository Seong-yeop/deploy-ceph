#!/usr/bin/env bash

if [[ $2 == 'down' ]]; then
	sudo sync
	sudo pkill -9 ceph-osd
	sleep 3
	sudo umount /dev/$1
	exit
fi


NODE=$(uname -n)
#NODE=hpc5
OSD=$(ceph osd create)

printf -v BAR '%.0s-' {1..79}

if [[ -z $1 ]]; then
  sudo parted -l
  printf "\nDEV: /dev/"
  read DEV
else
  DEV=$1
  MOUNT=$2
fi

DEV="/dev/$DEV"
DEST="/var/lib/ceph/osd/ceph-$OSD"

# umount
if mount | grep $DEV >/dev/null; then
	sudo umount $DEV
  sleep 3
fi
sudo rm -rf $HOME/log$OSD

# mkfs + mount
sudo rm -rf $DEST
sudo mkdir -p $DEST
mkdir -p /tmp/fdb /tmp/ceph
if sudo mkfs -t xfs -f -i size=2048 -- $DEV >/dev/null; then echo 'mkfs done'; fi
if [[ $MOUNT == 'true' ]]; then
  sudo mount -o noatime,inode64 -- $DEV $DEST
fi

#sudo gdb --args ceph-osd -i $OSD --mkfs --mkkey -d
sudo ceph-osd -i $OSD --mkfs --mkkey -d &>/tmp/ceph/mkfs.out

# Set crush
exec 3>&1
exec 1>/tmp/ceph/deploy.log
exec 2>&1
sudo ceph auth add osd.$OSD osd 'allow *' mon 'allow profile osd' -i $DEST/keyring 
ceph osd crush add-bucket $NODE host
ceph osd crush move $NODE root=default
ceph osd crush add osd.$OSD 1.0 host=$NODE
exec 1>&3
exec 2>&1

#sudo bash -c "ulimit -n 65536 && gdb --args ceph-osd -i $OSD -d "
#sudo bash -c "ulimit -n 65536 && ceph-osd -i $OSD -d &>/tmp/ceph/ceph.out" &
sudo bash -c "ulimit -n 65536 && ceph-osd -i $OSD"
#sudo ceph-osd -i $OSD

echo -e "\n$BAR"
sleep 3; ceph osd tree
echo -e "\nosd-$OSD is now deployed."
