#!/usr/bin/env bash

mkdir -p /data

echo COCO=$COCO
echo THREADS=$THREADS

echo python multithread_generate_benchmark.py --coco=$COCO --theads=$THREADS
python multithread_generate_benchmark.py --coco=$COCO --theads=$THREADS
#sync && echo 3 > /proc/sys/vm/drop_caches
#python multithread_read_benchmark.py
#rm -rf tmp
