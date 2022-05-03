#!/usr/bin/env bash
set -x

#mkdir -p tmp
#python multithread_generate_benchmark.py
# sync && echo 3 > /proc/sys/vm/drop_caches
echo THREADS=$THREADS
echo WORKERS_PER_NODE=$WORKERS_PER_NODE
echo WORKERS=$WORKERS

mpirun --allow-run-as-root --bind-to none -np ${WORKERS} -npernode ${WORKERS_PER_NODE} \
     --mca btl_tcp_if_include eth0 \
     --mca orte_keep_fqdn_hostnames t \
     --oversubscribe \
     date;time python /app/multithread_read_benchmark.py --threads=$THREADS;date
#rm -rf tmp
