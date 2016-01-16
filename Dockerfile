FROM centos:7.2.1511

ENV H2O_VERSION 1.6.2

RUN yum groupinstall -y "Development Tools" && \
    yum install -y cmake libyaml-devel openssl-devel ruby && \
    yum clean all

RUN cd /usr/local/src && \
    curl -LO https://github.com/h2o/h2o/archive/v${H2O_VERSION}.tar.gz && \
    tar zxvf v${H2O_VERSION}.tar.gz && \
    rm v${H2O_VERSION}.tar.gz
COPY /h2o/mruby-redis.patch /usr/local/src/h2o-${H2O_VERSION}
RUN cd /usr/local/src/h2o-${H2O_VERSION} && \
    patch -p0 < mruby-redis.patch && \
    cmake -DWITH_MRUBY=ON . && make && make install && \
    cd .. && rm -rf h2o-${H2O_VERSION}#

WORKDIR /app
COPY /app .
CMD h2o -c h2o.conf
