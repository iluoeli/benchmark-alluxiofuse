## AlluxioFUSE多线程读取测试文档

1. 创建并推送镜像

MPI的部分被注释掉了，如果需要MPI，取消注释即可

```bash
docker build -t bench-fuse:v0 -f Dockerfile .
docker tag bench-fuse:v0 iluoeli/bench-fuse:v0
docker push iluoeli/bench-fuse:v0
```

NOTE：最好推送到阿里云的镜像仓库，速度快一些

2. 生成测试数据

```bash
docker run -itd -v /tmp/data:/data --env WORKERS=1 --env WORKERS_PER_NODE=1 --env THREADS=1 --env COCO=1 bench-fuse:v0 /app/generate_file.sh
```

其中，
- `WORKERS`表示节点数量（没有意义，可不管）
- `WORKERS_PER_NODE`表示每个节点上的进程数量
- `THREADS`表示每个进程的线程数量（因为python是假的多线程机制，所以建议此参数不要超过8，结合`WORKERS_PER_NODE`来增加并发度）

运行如下命令可以简单测试一下读取性能:

```bash
docker run -itd -v /tmp/data:/data --env WORKERS=1 --env WORKERS_PER_NODE=2 --env THREADS=1 bench-fuse:v0 /app/read_file.sh
```

3. 安装fluid

参考fluid文档

4. 挂载Dataset

给生成测试数据的节点打标签

```bash
kubectl label nodes cn-beijing.172.16.0.147 coco=coco
```

创建Dataset和Runtime

```bash
cat <<EOF > dataset.yaml
apiVersion: data.fluid.io/v1alpha1
kind: Dataset
metadata:
  name: coco
spec:
  mounts:
  - mountPoint: local:///tmp/data
    name: coco
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
            - key: coco
              operator: In
              values:
                - coco
---
apiVersion: data.fluid.io/v1alpha1
kind: AlluxioRuntime
metadata:
  name: coco
spec:
  replicas: 1
  data:
    replicas: 1
  tieredstore:
    levels:
      - mediumtype: MEM
        path: /alluxio/ram 
        quota: 50Gi
        high: "0.99"
        low: "0.8"
EOF

kubectl create -f dataset.yaml
```

5. 运行分布式多线程读取测试

```bash
cat <<EOF > benchmark-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: alluxiofuse-benchmark-job
  labels:
    jobgroup: alluxiofuse-benchmark
spec:
  completions: 1
  parallelism: 1
  template:
    metadata:
      name: alluxiofuse-benchmark-job
      labels:
        jobgroup: alluxiofuse-benchmark
    spec:
      containers:
      - name: alluxiofuse-benchmark-job
        image: iluoeli/bench-fuse:v0
        command: ["/app/read_file.sh"]
        volumeMounts:
          - mountPath: /data
            name: coco
        env:
          - name: WORKERS_PER_NODE
            value: "1"
          - name: THREADS
            value: "1"
          - name: DATA_PATH
            value: "/data/coco"
      volumes:
        - name: coco
          persistentVolumeClaim:
            claimName: coco
      restartPolicy: OnFailure
EOF
      
kubectl create -f benchmark-job.yaml
```

NOTE：
- 记得保证容器镜像`image`和你的一样
- 调整`completions`和`parallelism`进行分布式多节点测试

6. 查看测试结果

```bash
kubectl logs alluxiofuse-benchmark-job-xxxxx
```