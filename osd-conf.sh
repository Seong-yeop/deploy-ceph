#!/bin/env bash

#osd_ip=("172.31.12.188" "172.31.10.228" "172.31.5.190" "172.31.3.16")
#osd_ip=("172.31.15.56" "172.31.4.56" "172.31.3.102" "172.31.11.243")
osd_ip=("172.31.7.126" "172.31.11.202" "172.31.9.73" "172.31.2.162")
  #"172.31.0.147" "172.31.8.243" "172.31.11.35" "172.31.4.2")

for i in "${osd_ip[@]}"; do
  echo $i osd ceph.conf ceph.keyring copy start
  scp -i /home/ubuntu/.ssh/csl.pem /etc/ceph/ceph.conf root@$i:/etc/ceph/ceph.conf
  scp -i /home/ubuntu/.ssh/csl.pem /var/lib/ceph/bootstrap-osd/ceph.keyring root@$i:/var/lib/ceph/bootstrap-osd/ceph.keyring
  scp -i /home/ubuntu/.ssh/csl.pem osd-deploy.sh root@$i:/home/ubuntu
  echo $i osd done
done

for i in "${osd_ip[@]}"; do
  ssh -i /home/ubuntu/.ssh/csl.pem root@$i bash /home/ubuntu/osd-deploy.sh &
done
wait

echo "all finised"



