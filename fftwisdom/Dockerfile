FROM arm64v8/ubuntu:24.04 AS base
ARG uid

# Create a user with sudo rights
RUN apt-get update && apt-get -y install sudo
RUN sed -i -e 's/\(sudo\tALL=(ALL:ALL) \)\(ALL\)/\1NOPASSWD:\2/' /etc/sudoers
RUN usermod -m -d /home/sdr -l sdr ubuntu
RUN groupmod --new-name sdr ubuntu
USER sdr

RUN sudo apt-get update && sudo apt-get -y install \
    libfftw3-dev

COPY --chown=sdr fftwisdom.sh /home/sdr/fftwisdom.sh
WORKDIR /home/sdr

SHELL ["/bin/bash", "-c"]
CMD "/home/sdr/fftwisdom.sh"
