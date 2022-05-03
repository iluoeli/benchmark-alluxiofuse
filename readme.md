

1.产生数据

a.生成小文件
# 一个COCO代表6.3GB， THREADS代表产生线程
# docker run -v /tmp/data:/data --env COCO=1 --env THREADS=1 -itd --name=generate-file registry.cn-huhehaote.aliyuncs.com/tensorflow-samples/coco-perf /app/generate_file.sh

b.生成文件，下载tf-record文件, 并且解压

wget https://imagenet-tgz.oss-cn-hongkong.aliyuncs.com/imagenet_data.tar

2.清理缓存
# sync && echo 3 > /proc/sys/vm/drop_caches


3.运行读文件程序，通过WORKERS设置总的进程数,通过WORKERS_PER_NODE设置每个节点的进程数，通过THREADS设置读文件的线程数 (目前为单机版，WORKERS=WORKERS_PER_NODE)

# docker run -v /alluxio-fuse/train:/data -itd --name=read-imagenet-1x8-8-memory \
--env WORKERS=8 --env WORKERS_PER_NODE=8 --env THREADS=8  \
registry.cn-shanghai.aliyuncs.com/tensorflow-samples/coco-perf-mpi:py2
docker logs -f read-imagenet-1x8-8-memory

