FROM ubuntu:16.04

ENV archive "make-3.82.tar.gz"
ENV make_url "http://ftp.gnu.org/gnu/make/${archive}"
ENV make_dir "/root/make"
ENV sha256sum "3d991b33e604187c5881a0abc2e102d5b9776da5569640e73778f85d617242e7"

ARG USER_ID
ARG GROUP_ID

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common apt-utils && \
    dpkg --add-architecture i386 && \
    add-apt-repository multiverse && \
    add-apt-repository -y ppa:webupd8team/java && \
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
        oracle-java6-installer \
        virtualbox \
        curl \
        vim \
        yasm && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir $make_dir && \
    curl $make_url -o ${make_dir}/${archive} && \
    cd ${make_dir}/ && \
    echo '3d991b33e604187c5881a0abc2e102d5b9776da5569640e73778f85d617242e7  make-3.82.tar.gz' | sha256sum -c '-' && \
    /bin/tar --extract --gzip --strip-components=1 --file ${archive} && \
    ./configure && \
    make && \
    cp -a "${make_dir}/make" "/usr/local/bin/make-3.82" && \
    addgroup --gid $GROUP_ID developer && \
    adduser --uid $USER_ID --gid $GROUP_ID --disabled-login --gecos "" developer

USER developer
WORKDIR /home/developer

