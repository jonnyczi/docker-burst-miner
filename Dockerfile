FROM arm32v7/fedora
MAINTAINER Administator email: czijonny@gmail.com

COPY mine /

RUN yum install -y sudo git make cmake3 wget gcc-c++ openssl-devel findutils hostname \

    && cd / \
    && git clone https://github.com/Creepsky/creepMiner.git \
    && cd /creepMiner \
    && chmod +x install-poco.sh \
    && ./install-poco.sh \
    && cmake -DCMAKE_BUILD_TYPE=RELEASE \
    && make \
    && make install \
    && mv bin /miner \

    && cd / \
    && rm -rf creepMiner \
    && yum erase -y git make cmake3 wget openssl-devel \
    && yum clean all \
    && rm -rf /var/cache/yum \

    && LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib \
    && export LD_LIBRARY_PATH \
    && chmod +x mine

EXPOSE 8080

ENTRYPOINT ./mine