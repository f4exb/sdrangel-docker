FROM node:slim as base

# Install base packages
RUN apt-get update && apt-get -y install sudo git
RUN npm install -g @angular/cli \
    && npm install -g http-server

# Give node user sudo rights and default to it
RUN usermod -a -G sudo node \
    && usermod --shell /bin/bash node
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER node

RUN sudo mkdir /opt/build \
    && sudo chown node:node /opt/build
WORKDIR /opt/build

# Clone sdrangelcli and build final image
FROM base as sdrangelcli
ARG branch
ARG clone_label
RUN git clone https://github.com/f4exb/sdrangelcli.git -b ${branch} sdrangelcli \
    && echo "${clone_label}" > /dev/null
WORKDIR /opt/build/sdrangelcli
RUN npm install \
    && ng build --prod \
    && mv dist /opt/build \
    && rm -rf *

WORKDIR /opt/build/dist/sdrangelcli
ENTRYPOINT [ "http-server" ]
