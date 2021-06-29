ceph osd pool create rbd_repl_bench 8 8 
rbd create img_repl_bench --size 4096000 --pool rbd_repl_bench
rbd feature disable rbd_repl_bench/img_repl_bench object-map fast-diff deep-flatten
rbd map rbd_repl_bench/img_repl_bench 

sleep 5
mkfs.ext4 /dev/rbd

