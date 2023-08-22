FROM ubuntu:18.04 AS base

# Create a user with sudo rights
RUN apt-get update && apt-get -y install sudo
RUN useradd -m wsjtx && echo "wsjtx:wsjtx" | chpasswd \
   && adduser wsjtx sudo \
   && usermod -a -G audio,dialout,plugdev wsjtx\
   && sudo usermod --shell /bin/bash wsjtx
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER wsjtx

# Install some prerequisites
RUN sudo apt-get update && sudo apt-get -y install build-essential \
    gcc \
    g++ \
    gfortran-7 \
    cmake \
    asciidoctor \
    qt5-default \
    qtbase5-dev \
    qtchooser \
    libqt5multimedia5-plugins \
    qtmultimedia5-dev \
    qttools5-dev \
    qttools5-dev-tools \
    qtbase5-dev \
    libqt5serialport5-dev \
    libfftw3-dev \
    texinfo \
    texi2html \
    libudev-dev

# Install more prerequisites
RUN sudo apt-get update && sudo apt-get -y install wget \
    git \
    subversion \
    vim \
	iputils-ping \
	traceroute \
	iproute2 \
    net-tools \
    pulseaudio \
    autoconf \
    libtool \
    libusb-1.0-0-dev

# Prepare buiid and install environment
RUN sudo mkdir /opt/build /opt/install \
    && sudo chown wsjtx:wsjtx /opt/build /opt/install

# Download WSJT-X
FROM base as get-wsjtx
ARG wsjtx_version
WORKDIR /opt/build
RUN wget --no-check-certificate https://physics.princeton.edu/pulsar/k1jt/wsjtx-${wsjtx_version}.tgz \
    && tar -xf wsjtx-${wsjtx_version}.tgz
WORKDIR /opt/build/wsjtx-${wsjtx_version}

# Build WSJT-X
FROM get-wsjtx as wsjtx
ARG nb_cores
RUN mkdir build; cd build \
    && FC=/usr/bin/gfortran-7 cmake -Wno-dev -DWSJT_SKIP_MANPAGES=ON -DCMAKE_INSTALL_PREFIX=/opt/install/wsjtx .. \
    && FC=/usr/bin/gfortran-7 make -j${nb_cores} \
    && FC=/usr/bin/gfortran-7 make install

# Clone and build libfaketime
FROM base as libfaketime
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/wolfcw/libfaketime.git
WORKDIR /opt/build/libfaketime
RUN make -j${nb_cores}
RUN DESTDIR="/opt/install/libfaketime" PREFIX="" make install

# Final image
FROM base as final
COPY --from=wsjtx --chown=wsjtx /opt/install /opt/install
COPY --from=libfaketime --chown=wsjtx /opt/install /opt/install
COPY --chmod=755 start.sh /start.sh
ENV LD_PRELOAD="/opt/install/libfaketime/lib/faketime/libfaketime.so.1"
ENTRYPOINT ["/start.sh"]
