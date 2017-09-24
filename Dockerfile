FROM centos:latest
MAINTAINER Administator email: czijonny@gmail.com

RUN yum install -y epel-release
RUN yum install -y sudo git make cmake3 wget openssl-devel deltarpm
RUN yum install -y centos-release-scl
RUN yum-config-manager --enable rhel-server-rhscl-7-rpms
RUN yum update -y
RUN yum upgrade -y
RUN yum install -y devtoolset-4-toolchain
RUN ln -s /bin/cmake3 /bin/cmake

WORKDIR /
RUN git clone https://github.com/Creepsky/creepMiner.git
WORKDIR /creepMiner
RUN chmod +x install-poco.sh
RUN scl enable devtoolset-4 ./install-poco.sh
RUN scl enable devtoolset-4 'cmake -DCMAKE_BUILD_TYPE=RELEASE'
RUN make
RUN make install
RUN mv bin /miner

WORKDIR /
RUN rm -rf creepMiner
RUN yum remove -y sudo git make cmake3 wget openssl-devel deltarpm centos-release-scl devtoolset-4-toolchain
RUN yum remove -y epel-release

RUN LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
RUN export LD_LIBRARY_PATH

COPY mine /
RUN chmod +x mine

EXPOSE 8080

ENTRYPOINT ./mine