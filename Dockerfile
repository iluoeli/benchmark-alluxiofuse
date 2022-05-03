# docker build -t bench-fuse:v0 -f Dockerfile . 
FROM python:2.7.17-alpine3.10

# Aliyun mirror
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# Add HDF5 support
RUN apk --no-cache --update-cache add gcc gfortran  build-base bash

RUN python -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip

RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple numpy six

# Install mpi
#RUN wget http://www.mpich.org/static/downloads/3.3.2/mpich-3.3.2.tar.gz && \
#  tar -zxvf mpich-3.3.2.tar.gz && \
#  cd mpich-3.3.2 && \
#  ./configure --prefix=/usr/local/mpich && \
#  make && make install

#ENV PATH "/usr/local/mpich/bin:$PATH"

RUN mkdir /app

ADD . /app

RUN chmod u+x /app/*.sh

ENV COCO 10

ENV WORKERS 1

ENV WORKERS_PER_NODE 1

ENV THREADS 1

ADD mpihost /etc/mpihost

ENV OMPI_MCA_orte_default_hostfile /etc/mpihost

WORKDIR /app

