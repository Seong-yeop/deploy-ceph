#!/bin/env bash

rgw_ip=("172.31.15.150")

cp ceph.conf /etc/ceph/ceph.conf
for i in "${rgw_ip[@]}"; do
  scp -i /home/ubuntu/.ssh/csl.pem /etc/ceph/ceph.conf root@$i:/etc/ceph/
  scp -i /home/ubuntu/.ssh/csl.pem /etc/ceph/ceph.client.admin.keyring root@$i:/etc/ceph/
  scp -i /home/ubuntu/.ssh/csl.pem rgw-deploy.sh root@$i:/home/ubuntu/
done

for i in "${rgw_ip[@]}"; do
  ssh -i /home/ubuntu/.ssh/csl.pem root@$i bash /home/ubuntu/rgw-deploy.sh &
done
wait

:<<'END'
rgw_ip=("172.31.0.152" "172.31.15.150" "172.31.0.11" "172.31.3.186"
  "172.31.12.74" "172.31.4.25" "172.31.6.126" "172.31.7.92")

for i in "${rgw_ip[@]}"; do
  scp -i /home/ubuntu/.ssh/csl.pem /etc/ceph/ceph.conf root@$i:/etc/ceph/
  scp -i /home/ubuntu/.ssh/csl.pem /etc/ceph/ceph.client.admin.keyring root@$i:/etc/ceph/
  scp -i /home/ubuntu/.ssh/csl.pem rgw-deploy.sh root@$i:/home/ubuntu/
done

for i in "${rgw_ip[@]}"; do
  ssh -i /home/ubuntu/.ssh/csl.pem root@$i bash /home/ubuntu/rgw-deploy.sh &
done
wait
END
echo "all finished"
