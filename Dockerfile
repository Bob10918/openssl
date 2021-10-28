FROM ubuntu:20.04
ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install git
RUN apt-get update
RUN apt-get install -y git

# get sources
RUN git clone https://github.com/XKCP/XKCP.git
RUN git clone https://github.com/Bob10918/liboqs.git
RUN git clone https://github.com/Bob10918/openssl.git

# install liboqs
RUN apt-get update
RUN apt-get install -y astyle cmake gcc ninja-build libssl-dev python3-pytest python3-pytest-xdist unzip xsltproc doxygen graphviz
WORKDIR /XKCP
RUN make AVX2/libXKCP.a
RUN cp -r bin/AVX2/libXKCP.a.headers /usr/include/libkeccak.a.headers
RUN cp bin/AVX2/libXKCP.a /usr/lib/libkeccak.a
WORKDIR /liboqs
RUN mkdir build
WORKDIR /liboqs/build
RUN cmake -GNinja -DCMAKE_INSTALL_PREFIX=/openssl/oqs -DOQS_BUILD_ONLY_LIB=ON -DOQS_DIST_BUILD=ON .. 
RUN ninja && ninja install

# install openssl-oqs
RUN apt-get install -y cmake gcc libtool libssl-dev make ninja-build git
WORKDIR /openssl
ENV LIBOQS_SRC_DIR=/liboqs
RUN ./Configure shared linux-x86_64 -lm -lkeccak
RUN make -j 8
