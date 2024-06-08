FROM debian:bookworm AS base
ARG uid

ENV DEBIAN_FRONTEND=noninteractive

# Create a user with sudo rights
RUN apt-get update && apt-get -y install sudo
RUN useradd -m sdr -u ${uid} && echo "sdr:sdr" | chpasswd \
   && adduser sdr sudo \
   && usermod -a -G audio,dialout,plugdev sdr\
   && sudo usermod --shell /bin/bash sdr
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER sdr

# Configure tzdata manually before anything else
ENV TZONE=Europe/Paris
RUN sudo ln -fs /usr/share/zoneinfo/$TZONE /etc/localtime \
    && sudo apt-get update && sudo apt-get -y install tzdata

# Some essentials
RUN sudo apt-get update && sudo apt-get -y install \
    vim \
    iputils-ping \
    traceroute \
    iproute2 \
    nmap \
    net-tools \
    python3-requests \
    python3-flask

# Install base build packages dependencies - step 1
RUN sudo apt-get update && sudo apt-get -y install \
    git \
    cmake \
    g++ \
    pkg-config \
    autoconf \
    automake \
    libtool \
    libfftw3-dev \
    wget \
    libusb-1.0-0-dev \
    libusb-dev \
    libhidapi-dev

# Install base build packages dependencies - Qt5
RUN sudo apt-get update && sudo apt-get -y install \
    qtbase5-dev
RUN sudo apt-get update && sudo apt-get -y install \
    qtchooser \
    libqt5multimedia5-plugins \
    qtmultimedia5-dev \
    libqt5websockets5-dev
RUN sudo apt-get update && sudo apt-get -y install \
    libqt5opengl5-dev \
    libqt5quick5 \
    qml-module-qtlocation \
    qml-module-qtlocation \
    qml-module-qtpositioning \
    qml-module-qtquick-window2 \
    qml-module-qtquick-dialogs \
    qml-module-qtquick-controls \
    qml-module-qtquick-controls2 \
    qml-module-qtquick-layouts \
    libqt5serialport5-dev \
    libqt5charts5-dev \
    qtdeclarative5-dev \
    qtpositioning5-dev \
    qtlocation5-dev \
    libqt5texttospeech5-dev \
    libqt5gamepad5-dev \
    qtwebengine5-dev \
    qtbase5-private-dev \
    libqt5svg5-dev

# Install base build packages dependencies - Boost
RUN sudo apt-get update && sudo apt-get -y install \
    libpython3-dev
RUN sudo apt-get update && sudo apt-get -y install \
    librdmacm1
RUN sudo apt-get update && sudo apt-get -y install \
    libboost-all-dev

# Install base build packages dependencies - the rest
RUN sudo apt-get update && sudo apt-get -y install \
    libasound2-dev \
    pulseaudio \
    libopencv-dev \
    libxml2-dev \
    bison \
    flex \
    ffmpeg \
    libavcodec-dev \
    libavformat-dev \
    libopus-dev \
    libfaad-dev \
    zlib1g-dev \
    libhamlib-dev

# Install compiled libraries dependencies
# Codec2
RUN sudo apt-get update && sudo apt-get -y install libspeexdsp-dev \
    libsamplerate0-dev
# Perseus
RUN sudo apt-get update && sudo apt-get -y install xxd
# XTRX (f4exb), UHD
RUN sudo apt-get update && sudo apt-get -y install \
    python3 python3-cheetah \
    python3-mako

# Prepare buiid and install environment
RUN sudo mkdir /opt/build /opt/install \
    && sudo chown sdr:sdr /opt/build /opt/install

# Clone repositories sequentially
FROM base as base_clones
WORKDIR /opt/build
#   APTdec
RUN git clone --depth 1 -b libaptdec https://github.com/srcejon/aptdec.git
#   CM256cc
RUN git clone --depth 1 -b v1.1.0 https://github.com/f4exb/cm256cc.git
#   LibDAB
RUN git clone --depth 1 -b msvc https://github.com/srcejon/dab-cmdline
#   MBElib
RUN git clone --depth 1 https://github.com/szechyjs/mbelib.git
#   SerialDV
RUN git clone --depth 1 -b v1.1.4 https://github.com/f4exb/serialDV.git
#   DSDcc
RUN git clone --depth 1 -b v1.9.3 https://github.com/f4exb/dsdcc.git
#   Codec2
RUN git clone --depth 1 -b v1.0.3 https://github.com/drowe67/codec2-dev.git codec2
#   libsigmf
RUN git clone --depth 1 -b new-namespaces https://github.com/f4exb/libsigmf.git \
    && cd libsigmf \
    && git submodule init \
    && git submodule update --depth 1 \
    && cd ..
#   SGP4
RUN git clone --depth 1 https://github.com/dnwrnr/sgp4.git
#   GGMorse
RUN git clone --depth 1 https://github.com/f4exb/ggmorse.git
#   Airspy
RUN git clone --depth 1 https://github.com/airspy/airspyone_host.git libairspy
#   RTL-SDR
RUN git clone --depth 1 -b v2.0.1 https://github.com/osmocom/rtl-sdr.git librtlsdr
#   PlutoSDR (libiio)
RUN git clone --depth 1 -b v0.21 https://github.com/analogdevicesinc/libiio.git
#   BladeRF
RUN git clone --depth 1 -b 2023.02 https://github.com/Nuand/bladeRF.git \
    && cd bladeRF \
    && git submodule init \
    && git submodule update --depth 1
#   HackRF
RUN git clone --depth 1 -b v2022.09.1 https://github.com/greatscottgadgets/hackrf.git
#   LimeSDR
RUN wget https://github.com/myriadrf/LimeSuite/archive/refs/tags/v22.09.0.tar.gz \
    && tar -xf v22.09.0.tar.gz \
    && ln -s LimeSuite-22.09.0 LimeSuite \
    && cd LimeSuite \
    && mkdir builddir
#   Airspy HF
RUN git clone --depth 1 https://github.com/airspy/airspyhf
#   Perseus
RUN git clone --depth 1 -b fixes https://github.com/f4exb/libperseus-sdr.git
#   XTRX
RUN git clone --depth 1 https://github.com/f4exb/images.git xtrx-images \
    && cd xtrx-images \
    && git submodule init \
    && git submodule update --depth 1 \
    && cd ..
#   UHD
RUN git clone --depth 1 -b v4.3.0.0 https://github.com/EttusResearch/uhd.git
#   SDRPlay RSP1
RUN git clone https://github.com/f4exb/libmirisdr-4.git
#   SDRangel
ARG sdrangel_tag
RUN mkdir sdrangel \
    && cd sdrangel \
    && git init \
    && git remote add origin https://github.com/f4exb/sdrangel.git \
    && git fetch --depth 1 origin ${sdrangel_tag} \
    && git checkout FETCH_HEAD \
    && cd ..

# Compile...
# APTdec
FROM base_clones AS aptdec
ARG nb_cores
WORKDIR /opt/build
RUN cd aptdec \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/aptdec .. \
    && make -j${nb_cores} install

# CM256cc
FROM base_clones AS cm256cc
ARG nb_cores
WORKDIR /opt/build
RUN cd cm256cc \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/cm256cc .. \
    && make -j${nb_cores} install

# LibDAB
FROM base_clones AS libdab
ARG nb_cores
WORKDIR /opt/build
RUN cd dab-cmdline/library \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libdab .. \
    && make -j${nb_cores} install

# MBElib
FROM base_clones AS mbelib
ARG nb_cores
WORKDIR /opt/build
RUN cd mbelib \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/mbelib .. \
    && make -j${nb_cores} install

# SerialDV
FROM base_clones AS serialdv
ARG nb_cores
WORKDIR /opt/build
RUN cd serialDV \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/serialdv .. \
    && make -j${nb_cores} install

# DSDcc
FROM base_clones AS dsdcc
ARG nb_cores
COPY --from=mbelib --chown=sdr /opt/install /opt/install
COPY --from=serialdv --chown=sdr /opt/install /opt/install
WORKDIR /opt/build
RUN cd dsdcc \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/dsdcc -DUSE_MBELIB=ON -DLIBMBE_INCLUDE_DIR=/opt/install/mbelib/include -DLIBMBE_LIBRARY=/opt/install/mbelib/lib/libmbe.so -DLIBSERIALDV_INCLUDE_DIR=/opt/install/serialdv/include/serialdv -DLIBSERIALDV_LIBRARY=/opt/install/serialdv/lib/libserialdv.so .. \
    && make -j${nb_cores} install

# Codec2
FROM base_clones AS codec2
ARG nb_cores
WORKDIR /opt/build
RUN cd codec2 \
    && mkdir build_linux; cd build_linux \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/codec2 .. \
    && make -j${nb_cores} install

# libsigmf
FROM base_clones AS libsigmf
ARG nb_cores
WORKDIR /opt/build
RUN cd libsigmf \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libsigmf .. \
    && make -j${nb_cores} install

# SGP4
FROM base_clones AS sgp4
ARG nb_cores
WORKDIR /opt/build
RUN cd sgp4 \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/sgp4 .. \
    && make -j${nb_cores} install

# GGMorse
FROM base_clones AS ggmorse
ARG nb_cores
WORKDIR /opt/build
RUN cd ggmorse \
    && mkdir build; cd build \
    && cmake -Wno-dev -DGGMORSE_BUILD_TESTS=OFF -DGGMORSE_BUILD_EXAMPLES=OFF -DCMAKE_INSTALL_PREFIX=/opt/install/ggmorse .. \
    && make -j${nb_cores} install

# SDRplay special
FROM base AS sdrplay
ENV SDRPLAY_MAJ 3.15
ENV SDRPLAY_MIN .2
ENV SDRPLAY_LIB libsdrplay_api
WORKDIR /opt/build
RUN mkdir -p /opt/install/libsdrplay/include \
    && mkdir -p /opt/install/libsdrplay/lib \
    && mkdir -p /opt/build/sdrplay
RUN cd sdrplay \
    && wget https://www.sdrplay.com/software/SDRplay_RSP_API-Linux-${SDRPLAY_MAJ}${SDRPLAY_MIN}.run \
    && export ARCH=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/) \
    && sh ./SDRplay_RSP_API-Linux-${SDRPLAY_MAJ}${SDRPLAY_MIN}.run --tar xvf \
    && cp ${ARCH}/${SDRPLAY_LIB}.so.${SDRPLAY_MAJ} /opt/install/libsdrplay/lib/. \
    && chmod 644 /opt/install/libsdrplay/lib/${SDRPLAY_LIB}.so.${SDRPLAY_MAJ} \
    && ln -s /opt/install/libsdrplay/lib/${SDRPLAY_LIB}.so.${SDRPLAY_MAJ} /opt/install/libsdrplay/lib/${SDRPLAY_LIB}.so.3 \
    && ln -s /opt/install/libsdrplay/lib/${SDRPLAY_LIB}.so.3 /opt/install/libsdrplay/lib/${SDRPLAY_LIB}.so \
    && cp inc/* /opt/install/libsdrplay/include \
    && chmod 644 /opt/install/libsdrplay/include/*

# Airspy
FROM base_clones AS airspy
ARG nb_cores
WORKDIR /opt/build
RUN cd libairspy \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libairspy .. \
    && make -j${nb_cores} install

# RTL-SDR
FROM base_clones AS rtlsdr
ARG nb_cores
WORKDIR /opt/build
RUN cd librtlsdr \
    && mkdir build; cd build \
    && cmake -Wno-dev -DDETACH_KERNEL_DRIVER=ON -DCMAKE_INSTALL_PREFIX=/opt/install/librtlsdr .. \
    && make -j${nb_cores} install

# PlutoSDR
FROM base_clones AS plutosdr
ARG nb_cores
WORKDIR /opt/build
RUN cd libiio \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libiio -DINSTALL_UDEV_RULE=OFF .. \
    && make -j${nb_cores} install

# BladeRF
FROM base_clones AS bladerf
ARG nb_cores
WORKDIR /opt/build
RUN cd bladeRF/host \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libbladeRF -DINSTALL_UDEV_RULES=OFF .. \
    && make -j${nb_cores} install
RUN mkdir /opt/install/libbladeRF/fpga \
    && wget -P /opt/install/libbladeRF/fpga https://www.nuand.com/fpga/v0.11.0/hostedxA4.rbf \
    && wget -P /opt/install/libbladeRF/fpga https://www.nuand.com/fpga/v0.11.0/hostedxA9.rbf \
    && wget -P /opt/install/libbladeRF/fpga https://www.nuand.com/fpga/v0.11.0/hostedx40.rbf \
    && wget -P /opt/install/libbladeRF/fpga https://www.nuand.com/fpga/v0.11.0/hostedx115.rbf

# HackRF
FROM base_clones AS hackrf
ARG nb_cores
WORKDIR /opt/build
RUN cd hackrf/host \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libhackrf -DINSTALL_UDEV_RULES=OFF .. \
    && make -j${nb_cores} install

# LimeSDR
FROM base_clones as limesdr
ARG nb_cores
RUN cd /opt/build/LimeSuite/builddir \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/LimeSuite .. \
    && make -j${nb_cores} install

# Airspy HF
FROM base_clones AS airspyhf
ARG nb_cores
WORKDIR /opt/build
RUN cd airspyhf \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libairspyhf .. \
    && make -j${nb_cores} install

# Perseus
FROM base_clones AS perseus
ARG nb_cores
WORKDIR /opt/build
RUN cd libperseus-sdr \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libperseus .. \
    && make \
    && make install

# XTRX
FROM base_clones AS xtrx
ARG nb_cores
WORKDIR /opt/build
RUN cd xtrx-images \
    && cd sources \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/xtrx-images -DENABLE_SOAPY=NO .. \
    && make -j${nb_cores} install

# UHD
FROM base_clones AS uhd
ARG nb_cores
WORKDIR /opt/build
RUN cd uhd/host \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/uhd \
    -DENABLE_PYTHON_API=OFF \
    -DENABLE_EXAMPLES=OFF \
    -DENABLE_TESTS=OFF \
    -DENABLE_E320=OFF \
    -DENABLE_E300=OFF \
    -DINSTALL_UDEV_RULES=OFF .. \
    && make -j${nb_cores} install
# Download firmware images for models requiring them at run time (see https://files.ettus.com/manual/page_images.html)
RUN /opt/install/uhd/lib/uhd/utils/uhd_images_downloader.py -t usrp1
RUN /opt/install/uhd/lib/uhd/utils/uhd_images_downloader.py -t b2xx
# RUN /opt/install/uhd/lib/uhd/utils/uhd_images_downloader.py -t e3xx_e310 - too big
# RUN /opt/install/uhd/lib/uhd/utils/uhd_images_downloader.py -t e3xx_e320_fpga - too big

# SDRPlay RSP1
FROM base_clones AS libmirisdr
ARG nb_cores
WORKDIR /opt/build
RUN cd libmirisdr-4 \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libmirisdr .. \
    && make -j${nb_cores} install

# Create a base image plus dependencies
FROM base AS base_deps
COPY --from=aptdec --chown=sdr /opt/install /opt/install
COPY --from=cm256cc --chown=sdr /opt/install /opt/install
COPY --from=libdab --chown=sdr /opt/install /opt/install
COPY --from=mbelib --chown=sdr /opt/install /opt/install
COPY --from=serialdv --chown=sdr /opt/install /opt/install
COPY --from=dsdcc --chown=sdr /opt/install /opt/install
COPY --from=codec2 --chown=sdr /opt/install /opt/install
COPY --from=libsigmf --chown=sdr /opt/install /opt/install
COPY --from=sgp4 --chown=sdr /opt/install /opt/install
COPY --from=ggmorse --chown=sdr /opt/install /opt/install
COPY --from=sdrplay --chown=sdr /opt/install /opt/install
COPY --from=airspy --chown=sdr /opt/install /opt/install
COPY --from=rtlsdr --chown=sdr /opt/install /opt/install
COPY --from=plutosdr --chown=sdr /opt/install /opt/install
COPY --from=bladerf --chown=sdr /opt/install /opt/install
COPY --from=hackrf --chown=sdr /opt/install /opt/install
COPY --from=limesdr --chown=sdr /opt/install /opt/install
COPY --from=airspyhf --chown=sdr /opt/install /opt/install
COPY --from=perseus --chown=sdr /opt/install /opt/install
COPY --from=xtrx --chown=sdr /opt/install /opt/install
COPY --from=libmirisdr --chown=sdr /opt/install /opt/install
COPY --from=uhd --chown=sdr /opt/install /opt/install
# This is to allow sharing pulseaudio with the host
COPY --chmod=644 pulse-client.conf /etc/pulse/client.conf

FROM base_clones AS sdrangel_clone
ARG clone_label
WORKDIR /opt/build
RUN cd sdrangel \
    && mkdir build \
    && echo "${clone_label}" > build/clone_label.txt

# Create a base image for all GUIs
FROM base_deps AS gui
ARG nb_cores
COPY --from=sdrangel_clone --chown=sdr /opt/build/sdrangel /opt/build/sdrangel
WORKDIR /opt/build/sdrangel/build
RUN cmake -Wno-dev -DDEBUG_OUTPUT=ON -DRX_SAMPLE_24BIT=ON -DBUILD_SERVER=OFF \
    -DMIRISDR_DIR=/opt/install/libmirisdr \
    -DAIRSPY_DIR=/opt/install/libairspy \
    -DAIRSPYHF_DIR=/opt/install/libairspyhf \
    -DBLADERF_DIR=/opt/install/libbladeRF \
    -DHACKRF_DIR=/opt/install/libhackrf \
    -DRTLSDR_DIR=/opt/install/librtlsdr \
    -DLIMESUITE_DIR=/opt/install/LimeSuite \
    -DIIO_DIR=/opt/install/libiio \
    -DAPT_DIR=/opt/install/aptdec \
    -DCM256CC_DIR=/opt/install/cm256cc \
    -DDSDCC_DIR=/opt/install/dsdcc \
    -DSERIALDV_DIR=/opt/install/serialdv \
    -DMBE_DIR=/opt/install/mbelib \
    -DCODEC2_DIR=/opt/install/codec2 \
    -DLIBSIGMF_DIR=/opt/install/libsigmf \
    -DDAB_DIR=/opt/install/libdab \
    -DSGP4_DIR=/opt/install/sgp4 \
    -DGGMORSE_DIR=/opt/install/ggmorse \
    -DPERSEUS_DIR=/opt/install/libperseus \
    -DXTRX_DIR=/opt/install/xtrx-images \
    -DUHD_DIR=/opt/install/uhd \
    -DCMAKE_INSTALL_PREFIX=/opt/install/sdrangel .. \
    && make -j${nb_cores} install
COPY --from=bladerf --chown=sdr /opt/install/libbladeRF/fpga /opt/install/sdrangel

# The final "vanilla" GUI version with no particular hardware dependencies
FROM gui AS vanilla
# Start SDRangel and some more services on which SDRangel depends
COPY --chmod=755 start_gui.sh /start.sh
COPY --chmod=755 restart_gui.sh /home/sdr/restart.sh
WORKDIR /home/sdr
ENTRYPOINT ["/start.sh"]

# The final "linux_nvidia" GUI version for running with NVidia GPU
FROM gui AS linux_nvidia
RUN sudo apt-get update && sudo apt-get install -y mesa-utils binutils kmod
# install nvidia driver
ADD NVIDIA-DRIVER.run /tmp/NVIDIA-DRIVER.run
RUN sudo sh /tmp/NVIDIA-DRIVER.run -s --ui=none --no-kernel-module --install-libglvnd --no-questions
RUN sudo rm /tmp/NVIDIA-DRIVER.run
# Start SDRangel and some more services on which SDRangel depends
COPY --chmod=755 start_gui.sh /start.sh
COPY --chmod=755 restart_gui.sh /home/sdr/restart.sh
WORKDIR /home/sdr
ENTRYPOINT ["/start.sh"]

# The final server version
FROM base_deps AS server
ARG rx_24bits
ARG nb_cores
COPY --from=sdrangel_clone --chown=sdr /opt/build/sdrangel /opt/build/sdrangel
WORKDIR /opt/build/sdrangel/build
RUN cmake -Wno-dev -DDEBUG_OUTPUT=ON -DRX_SAMPLE_24BIT=${rx_24bits} -DBUILD_GUI=OFF \
    -DMIRISDR_DIR=/opt/install/libmirisdr \
    -DAIRSPY_DIR=/opt/install/libairspy \
    -DAIRSPYHF_DIR=/opt/install/libairspyhf \
    -DBLADERF_DIR=/opt/install/libbladeRF \
    -DHACKRF_DIR=/opt/install/libhackrf \
    -DRTLSDR_DIR=/opt/install/librtlsdr \
    -DLIMESUITE_DIR=/opt/install/LimeSuite \
    -DIIO_DIR=/opt/install/libiio \
    -DAPT_DIR=/opt/install/aptdec \
    -DCM256CC_DIR=/opt/install/cm256cc \
    -DDSDCC_DIR=/opt/install/dsdcc \
    -DSERIALDV_DIR=/opt/install/serialdv \
    -DMBE_DIR=/opt/install/mbelib \
    -DCODEC2_DIR=/opt/install/codec2 \
    -DLIBSIGMF_DIR=/opt/install/libsigmf \
    -DDAB_DIR=/opt/install/libdab \
    -DSGP4_DIR=/opt/install/sgp4 \
    -DGGMORSE_DIR=/opt/install/ggmorse \
    -DPERSEUS_DIR=/opt/install/libperseus \
    -DXTRX_DIR=/opt/install/xtrx-images \
    -DCMAKE_INSTALL_PREFIX=/opt/install/sdrangel .. \
    && make -j${nb_cores} install
COPY --from=bladerf --chown=sdr /opt/install/libbladeRF/fpga /opt/install/sdrangel
# Start SDRangel and some more services on which SDRangel depends
COPY --chmod=755 start_server.sh /start.sh
COPY --chmod=755 restart_server.sh /home/sdr/restart.sh
WORKDIR /home/sdr
ENTRYPOINT ["/start.sh"]
