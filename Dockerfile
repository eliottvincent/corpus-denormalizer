# Version 0.0.1
FROM ubuntu:14.04

MAINTAINER Eliott Vincent "evincent@enssat.fr"

# base tools
RUN apt-get update

RUN apt-get install -y \
    build-essential \
    g++ \
    git \
    git-core \
    subversion \
    pkg-config \
    automake \
    libtool \
    wget \
    zlib1g-dev \
    python-dev \
    libbz2-dev \
    libboost-all-dev \
    liblzma-dev \
    libsoap-lite-perl \
    graphviz \
    imagemagick \
    make \
    cmake \
    libgoogle-perftools-dev \
    autoconf \
    doxygen

RUN mkdir -p /home/moses
WORKDIR /home/moses

# Build boost
#
RUN wget https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.gz
RUN tar zxvf boost_1_64_0.tar.gz
WORKDIR /home/moses/boost_1_64_0
RUN ./bootstrap.sh
RUN ./b2 -j4 --prefix=$PWD --libdir=$PWD/lib64 --layout=system link=static install || echo FAILURE

# Build cmph
#
WORKDIR /home/moses
RUN wget http://downloads.sourceforge.net/project/cmph/cmph/cmph-2.0.tar.gz
RUN tar zxvf cmph-2.0.tar.gz
WORKDIR /home/moses/cmph-2.0
RUN ./configure --prefix=/usr/local && make && make install prefix=/usr/local/cmph

# Build Moses
#
WORKDIR /home/moses
RUN git clone https://github.com/moses-smt/mosesdecoder.git
WORKDIR /home/moses/mosesdecoder
RUN ./bjam --with-boost=/home/moses/boost_1_64_0 --with-cmph=/usr/local/cmph -j4

# base samples (may be safe to remove)
WORKDIR /home/moses
RUN wget http://www.statmt.org/moses/download/sample-models.tgz
RUN tar xzf sample-models.tgz

# download samples
RUN mkdir /home/moses/corpus
WORKDIR /home/moses/corpus
RUN wget http://www.statmt.org/wmt13/training-parallel-nc-v8.tgz
RUN tar zxvf training-parallel-nc-v8.tgz

# copy and execute our workflow
COPY moses.sh /home/moses/moses.sh
RUN chmod +x /home/moses/moses.sh

CMD /home/moses/moses.sh

# OLD method to keep running the container
# CMD tail -f /dev/null
