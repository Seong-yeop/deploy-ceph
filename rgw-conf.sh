#!/bin/env bash

rgw_ip="172.31.4.82"

scp -i /home/ubuntu/.ssh/csl.pem /etc/ceph/ceph.conf root@$rgw_ip:/etc/ceph/
scp -i /home/ubuntu/.ssh/csl.pem /etc/ceph/ceph.client.admin.keyring root@$rgw_ip:/etc/ceph/
scp -i /home/ubuntu/.ssh/csl.pem rgw-deploy.sh root@$rgw_ip:/home/ubuntu/

ssh -i /home/ubuntu/.ssh/csl.pem root@$rgw_ip bash /home/ubuntu/rgw-deploy.sh
