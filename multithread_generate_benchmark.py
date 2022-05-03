import os
import time
import sys
import numpy as np
import uuid
from glob import glob
from threading import Thread
import argparse

from six.moves.queue import Queue


def worker(prefix, length_queue):
    while True:
        l = length_queue.get()
        if l is None:
            return
        content = np.random.bytes(l)
        f = open(prefix + str(uuid.uuid4()), "wb")
        f.write(content)
        f.close()


def write_db(workload_file, repeat_time, prefix, num_thread):
    lengths = []
    with open(workload_file) as fin:
        for l in fin:
            lengths.append(int(l))   

    lengths *= repeat_time

    length_queue = Queue()
    t1 = time.time()
    workers = [Thread(target=worker, args=(prefix, length_queue)) for _ in range(num_thread)]
    for w in workers:
        w.start()

    for i in lengths:
        length_queue.put(i)
    t2 = time.time()

    for i in range(len(workers)):
        length_queue.put(None)

    total_len = 6.3 * sum(lengths) * 1024 * 1024
    print("processing {} items with {} threads uses {}s, avg {}/s, avg {}B/s, avg {}MiB/s".format(sum(lengths), num_thread, (t2 - t1),
                                                          sum(lengths) / (t2 - t1), total_len / (t2 - t1), total_len / (t2 - t1)/1024/1024))



if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  # 10 coco means 63 GB, 52 coco means 327 GB
  parser.add_argument('--coco', type=int, default=10,
                      help='The number of coco, 1 coco means 6.3 GB.')
  parser.add_argument('--threads', type=int, default=2,
                      help='The number of threads')
  FLAGS, unparsed = parser.parse_known_args()
    # 1 coco means 6.3 GB   395COCO means 2.43T  208 coco means 1.25T
  # write_db("coco_workload.txt", 395, "/data", 256)
  write_db("coco_workload.txt", FLAGS.coco, "/data/", FLAGS.threads)
