FROM ubuntu:16.04

ARG USER_ID
ARG GROUP_ID

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common apt-utils && \
    dpkg --add-architecture i386 && \
    add-apt-repository multiverse && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get -y update && \
    (echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections) && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        adduser \
        build-essential \
        bc \
        ccze \
        git \
        zip \
        flex \
        bison \
        gperf \
        libxml2-utils \
        libstdc++6:i386 \
        libgcc1:i386 \
        zlib1g:i386 \
        libncurses5:i386 \
        openjdk-7-jdk \
        virtualbox \
        curl \
        vim \
        yasm && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    addgroup --gid $GROUP_ID developer && \
    adduser --uid $USER_ID --gid $GROUP_ID --disabled-login --gecos "" developer

USER developer
WORKDIR /home/developer

