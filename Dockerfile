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
RUN cmake -GNinja -DCMAKE_INSTALL_PREFIX=/openssl/oqs -DOQS_ENABLE_KEM_BIKE=OFF -DOQS_ENABLE_KEM_FRODOKEM=OFF -DOQS_ENABLE_KEM_SIKE=OFF \
                    -DOQS_ENABLE_KEM_SIDH=OFF -DOQS_ENABLE_SIG_PICNIC=OFF -DOQS_ENABLE_KEM_CLASSIC_MCELIECE=OFF -DOQS_ENABLE_KEM_HQC=OFF \
                    -DOQS_ENABLE_KEM_KYBER=OFF -DOQS_ENABLE_KEM_NTRU=OFF -DOQS_ENABLE_KEM_NTRUPRIME=OFF -DOQS_ENABLE_KEM_SABER=OFF \
                    -DOQS_ENABLE_SIG_DILITHIUM=OFF -DOQS_ENABLE_SIG_FALCON=OFF -DOQS_ENABLE_SIG_RAINBOW=OFF -DOQS_ENABLE_SIG_SPHINCS=OFF \
                    -DOQS_ENABLE_SIG_PICNIC=OFF \
                    ..
RUN ninja && ninja install

# install openssl-oqs
RUN apt-get install -y cmake gcc libtool libssl-dev make ninja-build git
WORKDIR /openssl
ENV LIBOQS_SRC_DIR=/liboqs
#./Configure no-shared linux-x86_64 -DOQS_DEFAULT_GROUPS=\"p384_ledacrypt_36629:p384_ledacrypt_cpa_15373:X25519:ledacrypt_36629:ledacrypt_cpa_15373:ED448\" -lm -lkeccak
RUN ./Configure shared linux-x86_64 -DOQS_DEFAULT_GROUPS=\"ledacrypt_36629:ledacrypt_cpa_15373\" -lm -lkeccak
RUN make -j 8
