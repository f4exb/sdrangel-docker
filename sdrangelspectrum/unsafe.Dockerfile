FROM node:slim as base

# Install base packages
RUN apt-get update && apt-get -y install sudo git
RUN npm install -g @angular/cli@9 \
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
FROM base as sdrangelspectrum
ARG repository
ARG branch
ARG repo_hash
ARG clone_tag
RUN GIT_SSL_NO_VERIFY=true git clone ${repository} -b ${branch} sdrangelspectrum \
    && echo "${repo_hash}" > /dev/null \
    && echo "${clone_tag}" > /dev/null
WORKDIR /opt/build/sdrangelspectrum
RUN npm install \
    && ng build --prod \
    && mv dist /opt/build \
    && rm -rf *

WORKDIR /opt/build/dist/sdrangelspectrum
ENTRYPOINT [ "http-server", "-p 8081" ]
