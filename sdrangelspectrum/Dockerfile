FROM node:20-slim AS base

# Install base packages
RUN apt-get update && apt-get -y install sudo git
RUN npm install -g @angular/cli@15 \
     && npm install -g http-server

# Give node user sudo rights and default to it
RUN usermod -a -G sudo node \
     && usermod --shell /bin/bash node
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER node

RUN sudo mkdir /opt/build \
     && sudo chown node:node /opt/build
WORKDIR /opt/build

# Clone sdrangelspectrum and build final image
FROM base AS sdrangelspectrum
ARG branch
ARG clone_label
RUN git clone https://github.com/f4exb/sdrangelspectrum.git -b ${branch} --single-branch sdrangelspectrum \
    && echo "${clone_label}" > /dev/null
WORKDIR /opt/build/sdrangelspectrum
RUN npm install \
    && ng build --configuration production \
    && mv dist /opt/build \
    && rm -rf *

WORKDIR /opt/build/dist/sdrangelspectrum
ENTRYPOINT [ "http-server", "-p 8081" ]
