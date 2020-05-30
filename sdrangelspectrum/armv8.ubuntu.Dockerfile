FROM ubuntu:20.04 AS base
ARG uid

ENV DEBIAN_FRONTEND=noninteractive

# Install base packages
RUN apt-get update && apt-get -y install sudo git curl npm
RUN npm install npm -g \
    && npm cache clean -f \
    && npm install -g n \
    && n stable
RUN npm install -g @angular/cli \
    && npm install -g http-server

# Create node user with sudo rights and default to it
RUN useradd -m node -u ${uid} && echo "node:node" | chpasswd \
    && adduser node sudo \
    && sudo usermod --shell /bin/bash node
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER node

RUN sudo mkdir /opt/build \
    && sudo chown node:node /opt/build
WORKDIR /opt/build

# Clone sdrangelcli and build final image
FROM base as sdrangelspectrum
ARG branch
ARG clone_label
RUN git clone https://github.com/f4exb/sdrangelspectrum.git -b ${branch} sdrangelspectrum \
    && echo "${clone_label}" > /dev/null
WORKDIR /opt/build/sdrangelspectrum
RUN npm install \
    && ng build --prod \
    && mv dist /opt/build \
    && rm -rf *

WORKDIR /opt/build/dist/sdrangelspectrum
ENTRYPOINT [ "http-server", "-p 8081" ]
