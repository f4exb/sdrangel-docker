FROM node

# Install base packages
RUN apt-get update && apt-get -y install sudo
RUN npm install -g @angular/cli \
     && npm install -g http-server

# Give node user sudo rights and default to it
RUN usermod -a -G sudo node \
     && sudo usermod --shell /bin/bash node
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER node

RUN sudo mkdir /opt/build \
     && sudo chown node:node /opt/build
WORKDIR /opt/build
RUN git clone https://github.com/f4exb/sdrangelcli.git
WORKDIR /opt/build/sdrangelcli
RUN npm install \
     && ng build

WORKDIR /opt/build/sdrangelcli/dist/sdrangelcli
ENTRYPOINT [ "http-server" ]
