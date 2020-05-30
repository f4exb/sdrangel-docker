FROM arm64v8/node:alpine as base

# Install base packages
RUN apk update && apk add sudo git

RUN npm install -g @angular/cli@9 \
    && npm install -g http-server

# Give node user sudo rights and default to it
RUN addgroup node wheel
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
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
