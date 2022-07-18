FROM arm64v8/alpine AS base
ARG uid

# Create a user with sudo rights
RUN apk update && apk add sudo
RUN adduser \
    --disabled-password \
    --home /home/sdr \
    --ingroup users \
    --uid ${uid} sdr
RUN echo "sdr:sdr" | chpasswd \
    && addgroup sdr audio \
    && addgroup sdr dialout \
    && addgroup sdr wheel
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER sdr

# Some essentials
RUN sudo apk update && sudo apk add \
    vim \
    iputils \
    py-requests \
    py-flask

# Install base build packages dependencies - step 1
RUN sudo apk update && sudo apk add \
    git \
    make \
    cmake \
    g++ \
    pkgconf \
    autoconf \
    automake \
    libtool \
    fftw-dev \
    libusb-dev \
    libhidapi-dev

# Install base build packages dependencies - Qt5
RUN sudo apk update && sudo apk add \
    qt5-qtbase-dev \
    qt5-qtmultimedia-dev \
    qt5-websockets-dev \
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
    qtwebengine5-dev \
    qtbase5-private-dev

# Install base build packages dependencies - Boost
RUN sudo apk update && sudo apk add \
    boost-dev

# Install base build packages dependencies - the rest
RUN sudo apk update && sudo apk add \
    pulseaudio \
    libxml2-dev \
    bison \
    flex \
    ffmpeg-dev \
    opus-dev \
    speex-dev \
    speexdsp-dev \
    libsamplerate-dev \
    py-cheetah \
    py-mako \
    faad2-dev \
    zlib-dev

# Prepare buiid and install environment
RUN sudo mkdir /opt/build /opt/install \
    && sudo chown sdr:users /opt/build /opt/install

# APTdec
FROM base AS aptdec
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/srcejon/aptdec.git \
    && cd aptdec \
    && git checkout libaptdec \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/aptdec .. \
    && make -j${nb_cores} install

# CM256cc
FROM base AS cm256cc
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/f4exb/cm256cc.git \
    && cd cm256cc \
    && git reset --hard c0e92b92aca3d1d36c990b642b937c64d363c559 \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/cm256cc .. \
    && make -j${nb_cores} install

# LibDAB
FROM base AS libdab
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/srcejon/dab-cmdline \
    && cd dab-cmdline/library \
    && git checkout msvc \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libdab .. \
    && make -j${nb_cores} install

# MBElib
FROM base AS mbelib
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/szechyjs/mbelib.git \
    && cd mbelib \
    && git reset --hard 9a04ed5c78176a9965f3d43f7aa1b1f5330e771f \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/mbelib .. \
    && make -j${nb_cores} install

# SerialDV
FROM base AS serialdv
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/f4exb/serialDV.git \
    && cd serialDV \
    && git reset --hard "v1.1.4" \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/serialdv .. \
    && make -j${nb_cores} install

# DSDcc
FROM base AS dsdcc
ARG nb_cores
WORKDIR /opt/build
COPY --from=mbelib --chown=sdr /opt/install /opt/install
COPY --from=serialdv --chown=sdr /opt/install /opt/install
RUN git clone https://github.com/f4exb/dsdcc.git \
    && cd dsdcc \
    && git reset --hard "v1.9.3" \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/dsdcc -DUSE_MBELIB=ON -DLIBMBE_INCLUDE_DIR=/opt/install/mbelib/include -DLIBMBE_LIBRARY=/opt/install/mbelib/lib/libmbe.so -DLIBSERIALDV_INCLUDE_DIR=/opt/install/serialdv/include/serialdv -DLIBSERIALDV_LIBRARY=/opt/install/serialdv/lib/libserialdv.so .. \
    && make -j${nb_cores} install

# Codec2
FROM base AS codec2
ARG nb_cores
WORKDIR /opt/build
RUN sudo apk update && sudo apk add subversion
RUN git clone https://github.com/drowe67/codec2.git \
    && cd codec2 \
    && git reset --hard "v1.0.3" \
    && mkdir build_linux; cd build_linux \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/codec2 .. \
    && make -j${nb_cores} install

# libsigmf
FROM base AS libsigmf
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/f4exb/libsigmf.git \
    && cd libsigmf \
    && git checkout "new-namespaces" \
    && git reset --hard 8623f04c1e4e817ebcaacbe55265a7740da015a4 \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libsigmf .. \
    && make -j${nb_cores} install

# SGP4
FROM base AS sgp4
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/dnwrnr/sgp4.git \
    && cd sgp4 \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/sgp4 .. \
    && make -j${nb_cores} install

WORKDIR /opt/build

# Airspy
FROM base AS airspy
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/airspy/host.git libairspy \
    && cd libairspy \
    && git reset --hard bfb667080936ca5c2d23b3282f5893931ec38d3f \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libairspy .. \
    && make -j${nb_cores} install

# RTL-SDR
FROM base AS rtlsdr
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/osmocom/rtl-sdr.git librtlsdr \
    && cd librtlsdr \
    && git reset --hard dc92af01bf82b5185986190e3cde3762565d2194 \
    && mkdir build; cd build \
    && cmake -Wno-dev -DDETACH_KERNEL_DRIVER=ON -DCMAKE_INSTALL_PREFIX=/opt/install/librtlsdr .. \
    && make -j${nb_cores} install

# PlutoSDR
FROM base AS plutosdr
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/analogdevicesinc/libiio.git \
    && cd libiio \
    && git reset --hard "v0.21" \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libiio -DINSTALL_UDEV_RULE=OFF .. \
    && make -j${nb_cores} install

# BladeRF
FROM base AS bladerf
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/Nuand/bladeRF.git \
    && cd bladeRF/host \
    && git reset --hard "2019.07" \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libbladeRF -DINSTALL_UDEV_RULES=OFF .. \
    && make -j${nb_cores} install
RUN mkdir /opt/install/libbladeRF/fpga \
    && wget -P /opt/install/libbladeRF/fpga https://www.nuand.com/fpga/v0.11.0/hostedxA4.rbf \
    && wget -P /opt/install/libbladeRF/fpga https://www.nuand.com/fpga/v0.11.0/hostedxA9.rbf \
    && wget -P /opt/install/libbladeRF/fpga https://www.nuand.com/fpga/v0.11.0/hostedx40.rbf \
    && wget -P /opt/install/libbladeRF/fpga https://www.nuand.com/fpga/v0.11.0/hostedx115.rbf

# HackRF
FROM base AS hackrf
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/mossmann/hackrf.git \
    && cd hackrf/host \
    && git reset --hard "v2018.01.1" \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libhackrf -DINSTALL_UDEV_RULES=OFF .. \
    && make -j${nb_cores} install

# LimeSDR
FROM base AS limesdr_clone
WORKDIR /opt/build
RUN wget https://github.com/myriadrf/LimeSuite/archive/v20.01.0.tar.gz \
    && tar -xf v20.01.0.tar.gz \
    && ln -s LimeSuite-20.01.0 LimeSuite \
    && cd LimeSuite \
    && mkdir builddir

FROM limesdr_clone AS limesdr
ARG nb_cores
RUN cd /opt/build/LimeSuite/builddir \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/LimeSuite .. \
    && make -j${nb_cores} install

# Airspy HF
FROM base AS airspyhf
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/airspy/airspyhf \
    && cd airspyhf \
    && git reset --hard "1.1.5" \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libairspyhf .. \
    && make -j${nb_cores} install

# Perseus
FROM base AS perseus
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/f4exb/libperseus-sdr.git \
    && cd libperseus-sdr \
    && git checkout fixes \
    && git reset --hard afefa23e3140ac79d845acb68cf0beeb86d09028 \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/libperseus .. \
    && make \
    && make install

# XTRX
FROM base AS xtrx
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/xtrx-sdr/images.git xtrx-images \
    && cd xtrx-images \
    && git reset --hard 703cc42285b51e7b214e3b5d02c07f90b53c840e \
    && git submodule init \
    && git submodule update \
    && cd sources \
    && mkdir build; cd build \
    && cmake -Wno-dev -DCMAKE_INSTALL_PREFIX=/opt/install/xtrx-images -DENABLE_SOAPY=NO .. \
    && make -j${nb_cores} install

# UHD
FROM base AS uhd
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/EttusResearch/uhd.git \
    && cd uhd/host \
    && git reset --hard v3.15.0.0 \
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
FROM base AS libmirisdr
ARG nb_cores
WORKDIR /opt/build
RUN git clone https://github.com/f4exb/libmirisdr-4.git \
    && cd libmirisdr-4 \
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
# This is the first step to allow sharing pulseaudio with the host
COPY pulse-client.conf /etc/pulse/client.conf

FROM base AS sdrangel_clone
WORKDIR /opt/build
ARG branch
ARG sdrangel_tag
ARG clone_label
RUN git clone https://github.com/f4exb/sdrangel.git -b ${branch} sdrangel \
    && cd sdrangel \
    && git fetch origin ${sdrangel_tag} \
    && git reset --hard ${sdrangel_tag} \
    && mkdir build \
    && echo "${clone_label}" > build/clone_label.txt

# The final server version
FROM base_deps AS server
ARG rx_24bits
ARG nb_cores
COPY --from=sdrangel_clone --chown=sdr /opt/build/sdrangel /opt/build/sdrangel
WORKDIR /opt/build/sdrangel/build
RUN cmake -Wno-dev -DDEBUG_OUTPUT=ON -DBUILD_TYPE=RELEASE -DRX_SAMPLE_24BIT=${rx_24bits} -DBUILD_GUI=OFF \
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
    -DPERSEUS_DIR=/opt/install/libperseus \
    -DXTRX_DIR=/opt/install/xtrx-images \
    -DUHD_DIR=/opt/install/uhd \
    -DCMAKE_INSTALL_PREFIX=/opt/install/sdrangel .. \
    && make -j${nb_cores} install
COPY --from=bladerf --chown=sdr /opt/install/libbladeRF/fpga /opt/install/sdrangel
# Start SDRangel and some more services on which SDRangel depends
COPY start_server.armv8.sh /start.sh
COPY restart_server.armv8.sh /home/sdr/restart.sh
WORKDIR /home/sdr
ENTRYPOINT ["/start.sh"]
