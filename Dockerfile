FROM centos:latest as compiler
MAINTAINER Administator email: czijonny@gmail.com

RUN yum update \
    && yum -y install wget \
    && cd /etc/pki/rpm-gpg \
    && wget -O RPM-GPG-KEY-foreman http://yum.theforeman.org/releases/1.8/RPM-GPG-KEY-foreman \
    && rpm --import RPM-GPG-KEY-foreman \
    && yum update \
    && yum -y install epel-release \
    && yum provides '*/applydeltarpm' \
    && yum -y install deltarpm \
    && yum -y install centos-release-scl \
    && yum -y install devtoolset-4 cmake3 git python-pip deltarpm \
    && alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake 10 \
    --slave /usr/local/bin/ctest ctest /usr/bin/ctest \
    --slave /usr/local/bin/cpack cpack /usr/bin/cpack \
    --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake \
    --family cmake \
    && alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake3 20 \
    --slave /usr/local/bin/ctest ctest /usr/bin/ctest3 \
    --slave /usr/local/bin/cpack cpack /usr/bin/cpack3 \
    --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake3 \
    --family cmake

SHELL ["/usr/bin/scl", "enable", "devtoolset-4"]

RUN cd / \
    && pip install --upgrade pip \
    && pip install conan \
    && git clone https://github.com/Creepsky/creepMiner \
    && cd /creepMiner \
    && conan install . --build \
    && cmake CMakeLists.txt -DCMAKE_BUILD_TYPE=RELEASE -DNO_GPU=OFF -DUSE_CUDA=OFF -DUSE_OPENCL=OFF

RUN scl enable devtoolset-4 bash \
    && cd /creepMiner \
    && make

FROM centos:latest

COPY --from=compiler /creepMiner/bin/creepMiner /bin/creepMiner
COPY --from=compiler /creepMiner/resources/public/ /creepMiner/public
COPY --from=compiler /creepMiner/lib/* /usr/local/lib/

EXPOSE 8124

COPY mine /creepMiner/

RUN chmod +x /creepMiner/mine \
    && creepMiner \
    && mkdir /config \
    && mv /root/.creepMiner/*/mining.conf / \
    && rm -rf /root/.creepMiner \
    && sed -i 's/\/root\/\.creepMiner\/.*\/logs\//\/config\/logs\//g' mining.conf \
    && sed -i 's/\/root\/\.creepMiner\/.*\/data.db/\/config\/data.db/g' mining.conf

WORKDIR /creepMiner

ENTRYPOINT ./mine