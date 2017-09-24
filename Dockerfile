FROM centos:latest
MAINTAINER Administator email: czijonny@gmail.com

COPY mine /

RUN yum install -y epel-release \
    && yum install -y sudo git make cmake3 wget openssl-devel deltarpm \
    && yum install -y centos-release-scl \
    && yum-config-manager --enable rhel-server-rhscl-7-rpms \
    && yum update -y \
    && yum upgrade -y \
    && yum install -y devtoolset-4-toolchain \
    && ln -s /bin/cmake3 /bin/cmake \

    && cd / \
    && git clone https://github.com/Creepsky/creepMiner.git \
    && cd /creepMiner \
    && chmod +x install-poco.sh \
    && scl enable devtoolset-4 ./install-poco.sh \
    && scl enable devtoolset-4 'cmake -DCMAKE_BUILD_TYPE=RELEASE' \
    && make \
    && make install \
    && mv bin /miner \

    && cd / \
    && rm -rf creepMiner \
    && yum erase -y sudo git make cmake3 wget openssl-devel deltarpm centos-release-scl devtoolset-4-toolchain \
    && yum erase -y epel-release \
    && yum clean all \
    && rm -rf /var/cache/yum \

    && LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib \
    && export LD_LIBRARY_PATH \
    && chmod +x mine

EXPOSE 8080

ENTRYPOINT ./mine